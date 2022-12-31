Class {
	#name : #BlockContext,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'sender',
		'pc',
		'stackp'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
BlockContext class >> newForMethod: aMethod [
	"This is the only method for creating new contexts, other than by using the clone primitive. Any other attempts, such as inherited methods like shallowCopy, should be avoided or must at least be rewritten to determine the proper size for the method that will use this context. This is because asking a context its size (even basicSize!) will not return the actual object size but only the number of fields currently accessible, as determined by stackp."

	^ super basicNew: aMethod frameSize
]

{ #category : #all }
BlockContext >> blockCopy: numArgs [
	"Primitive. Distinguish a block of code from its enclosing method by creating a new BlockContext for that block. The compiler inserts into all methods that contain blocks the bytecodes to send the message blockCopy:. Do not use blockCopy: in code that you write! Only the compiler can decide to send the message blockCopy:. Fail if numArgs is not a SmallInteger. Optional. No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 80>
]

{ #category : #all }
BlockContext >> sender [
	"Answer the context that sent the message that created the receiver."

	^ sender
]

{ #category : #all }
BlockContext >> receiver [
	"Answer the context from which the message that created the receiver was sent."

	^ sender ifNotNil: [ sender receiver ]
]

{ #category : #all }
BlockContext >> tempAt: index [
	"Answer the value of the temporary variable whose index is the 
	 argument, index.  Primitive. Assumes receiver is indexable. Answer the
	 value of an indexable element in the receiver. Fail if the argument index
	 is not an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default at: primitive to give latitude to the
	 VM in context management."

	<primitive: 210>
	^self at: index
]

{ #category : #all }
BlockContext >> tempAt: index put: value [
	"Store the argument, value, as the temporary variable whose index is the 
	 argument, index.  Primitive. Assumes receiver is indexable. Answer the
	 value of an indexable element in the receiver. Fail if the argument index
	 is not an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default at:put: primitive to give latitude to
	 the VM in context management."

	<primitive: 211>
	
]

{ #category : #all }
BlockContext >> canHandleSignal: exception [
	"Sent to handler (on:do:) contexts only.  If my exception class (first arg) handles exception then return true, otherwise forward this message to the next handler context.  If none left, return false (see nil>>canHandleSignal:)"

	^ (self exceptionClass handles: exception)
		or: [ self nextHandlerContext canHandleSignal: exception ]
]

{ #category : #all }
BlockContext >> cannotReturn: result [
	self handleExceptionName: 'Cannot return, computation has been terminated' context: self
]

{ #category : #all }
BlockContext >> cannotReturn: result to: aContext [
	self handleExceptionName: 'Cannot return, computation has been terminated' context: aContext
]

{ #category : #all }
BlockContext >> evaluateSignal: exception [
	"The following primitive is just a marker used to find the evaluation context. 
	See Context>>#isHandlerOrSignalingContext. "

	<primitive: 199>
	| value |
	exception privHandlerContext: self.
	value := self exceptionHandlerBlock cull: exception.	
	"return from self if not otherwise directed in handle block"
	self return: value
]

{ #category : #all }
BlockContext >> findContextSuchThat: testBlock [
	"Search self and my sender chain for first one that satisfies testBlock.  Return nil if none satisfy"

	| context |
	context := self.
	[ context isNil ] whileFalse: [
		(testBlock value: context) 
			ifTrue: [ ^ context ].
		context := context sender ].
	^ nil
]

{ #category : #all }
BlockContext >> findNextHandlerContext [
	"Return the next handler marked context, returning nil if there is none.  Search starts with self and proceeds up to nil."

	| context |
	context := self findNextHandlerOrSignalingContext.
	context isNil
		ifTrue: [ ^ nil ].
	context isHandlerContext
		ifTrue: [ ^ context ].	"If it isn't a handler context, it must be a signaling context.
	When we reach a signaling context we must skip over any handlers
	that might be on the stack between the signaling context and the handler
	context for that signal."
	^ context exception privHandlerContext nextHandlerContext
]

{ #category : #all }
BlockContext >> findNextHandlerOrSignalingContext [
	"Return the next handler/signaling marked context, answering nil if there is none. 
	Search starts with self and proceeds up to nil."

	| context |
	<primitive: 197>
	context := self.
	[ 
	context isHandlerOrSignalingContext
		ifTrue: [ ^ context ].
	(context := context sender) == nil ] whileFalse.
	^ nil
]

{ #category : #all }
BlockContext >> findNextUnwindContextUpTo: aContext [
	"Return the next unwind marked above the receiver, returning nil if there is none.  Search proceeds up to but not including aContext."

	| context |
	<primitive: 195>
	context := self.
	[
		(context := context sender) == nil
		or: [ context == aContext ]
	] whileFalse: [
		context isUnwindContext
			ifTrue: [ ^context ]].
	^nil
]

{ #category : #all }
BlockContext >> handleSignal: exception [
	"Sent to handler (on:do:) contexts only.  If my exception class (first arg) handles exception then execute my handle block (second arg), otherwise forward this message to the next handler context.  If none left, execute exception's defaultAction (see nil>>handleSignal:)."

	(self exceptionClass handles: exception)
		ifFalse: [ ^ self nextHandlerContext handleSignal: exception ].
	self evaluateSignal: exception
]

{ #category : #all }
BlockContext >> isHandlerContext [
	"is this context for #on:do:?"
	^ false
]

{ #category : #all }
BlockContext >> isHandlerOrSignalingContext [
	"Both BlockClosure>>on:do: (handler) and BlockContext>>evaluateSignal: (signaling) 
	are marked with primitive 199."
	^ false
]

{ #category : #all }
BlockContext >> isUnwindContext [
	"is this context for  method that is marked?"
	^ false
]

{ #category : #all }
BlockContext >> nextHandlerContext [

	^ self sender findNextHandlerContext
]

{ #category : #all }
BlockContext >> isDead [
	"Has self finished"

	^ pc isNil
]

{ #category : #all }
BlockContext >> resume: value [
	"Unwind thisContext to self and resume with value as result of last send.  Execute unwind blocks when unwinding.  ASSUMES self is a sender of thisContext"
	
	self resume: value through: (thisContext findNextUnwindContextUpTo: self)
]

{ #category : #all }
BlockContext >> resume: value through: firstUnwindContext [
	"Unwind thisContext to self and resume with value as result of last send.
	 Execute any unwind blocks while unwinding.
	 ASSUMES self is a sender of thisContext."

	| context unwindBlock |

	self isDead 
		ifTrue: [ self cannotReturn: value to: self ].
	context := firstUnwindContext.
	[ context isNil ] whileFalse: [	
		context unwindComplete ifNil:[
			context unwindComplete: true.
			unwindBlock := context unwindBlock.
			thisContext terminateTo: context.
			unwindBlock value].
		context := context findNextUnwindContextUpTo: self].
	thisContext terminateTo: self.
	^ value
]

{ #category : #all }
BlockContext >> return: value [
	"Unwind thisContext to self and return value to self's sender.  Execute any unwind blocks while unwinding.  ASSUMES self is a sender of thisContext"

	sender ifNil: [ ^ self cannotReturn: value to: sender ].
	sender resume: value
]

{ #category : #all }
BlockContext >> hasSender: context [
	"Answer whether the receiver is strictly above context on the stack."

	| senderContext |
	self == context 
		ifTrue: [ ^ false ].
	senderContext := sender.
	[ senderContext == nil ]
		whileFalse: [
			senderContext == context
				ifTrue: [ ^ true ].
			senderContext := senderContext sender ].
	^ false
]

{ #category : #all }
BlockContext >> terminate [
	"Make myself unresumable."

	sender := nil.
	pc := nil.
]

{ #category : #all }
BlockContext >> terminateTo: previousContext [
	"Terminate all the Contexts between me and previousContext, if previousContext is on my Context stack. Make previousContext my sender."

	| currentContext sendingContext |
	<primitive: 196>
	(self hasSender: previousContext) ifTrue: [
		currentContext := sender.
		[currentContext == previousContext] whileFalse: [
			sendingContext := currentContext sender.
			currentContext terminate.
			currentContext := sendingContext ]].
	sender := previousContext
]

{ #category : #all }
BlockContext >> unwindTo: aContext [

	| context unwindBlock |
	context := self.
	[ (context := context findNextUnwindContextUpTo: aContext) isNil ] whileFalse: [
		(context unwindComplete) ifNil: [
			context unwindComplete: true.
			unwindBlock := context unwindBlock.
			unwindBlock value ]]
]

{ #category : #all }
BlockContext >> unwindBlock [
	"unwindContext only. access temporaries from BlockClosure>>#ensure: and BlockClosure>>#ifCurtailed:"
	^ self tempAt: 1
]

{ #category : #all }
BlockContext >> unwindComplete [
	"unwindContext only. access temporaries from BlockClosure>>#ensure: and BlockClosure>>#ifCurtailed:"
	^ self tempAt: 2
]

{ #category : #all }
BlockContext >> unwindComplete: aBoolean [
	"unwindContext only. access temporaries from BlockClosure>>#ensure: and BlockClosure>>#ifCurtailed:"
	self tempAt: 2 put: aBoolean
]

{ #category : #all }
BlockContext >> exception [
	"signaling context (BlockContext>>evaluateSignal:) only. Access the exception argument."
	^ self tempAt: 1
]

{ #category : #all }
BlockContext >> exceptionClass [
	"handlercontext only. access temporaries from BlockClosure>>#on:do:"
	^ self tempAt: 1
]

{ #category : #all }
BlockContext >> exceptionHandlerBlock [
	"handlercontext only. access temporaries from BlockClosure>>#on:do:"
	^ self tempAt: 2
]

{ #category : #all }
BlockContext >> return: value through: firstUnwindContext [
	"Unwind thisContext to self and return value to self's sender.
	 Execute any unwind blocks while unwinding.
	 ASSUMES self is a sender of thisContext."

	sender ifNil: [self cannotReturn: value to: sender].
	sender resume: value through: firstUnwindContext
]

{ #category : #all }
BlockContext >> printOn: aStream [
	"A quick way to show some context"

	aStream	nextPutAll: 'BlockContext'.
	aStream nextPut: Character lf.
	sender ifNotNil: [
		aStream nextPutAll: 'Called from: '.
		sender printOn: aStream ]
]
