Class {
	#name : #Context,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'sender',
		'pc',
		'stackp',
		'method',
		'closureOrNil',
		'receiver'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
Context class >> newForMethod: aMethod [
	"This is the only method for creating new contexts, other than by using the clone primitive. Any other attempts, such as inherited methods like shallowCopy, should be avoided or must at least be rewritten to determine the proper size for the method that will use this context. This is because asking a context its size (even basicSize!) will not return the actual object size but only the number of fields currently accessible, as determined by stackp."

	^ super basicNew: aMethod frameSize
]

{ #category : #all }
Context >> blockCopy: numArgs [
	"Primitive. Distinguish a block of code from its enclosing method by creating a new Context for that block. The compiler inserts into all methods that contain blocks the bytecodes to send the message blockCopy:. Do not use blockCopy: in code that you write! Only the compiler can decide to send the message blockCopy:. Fail if numArgs is not a SmallInteger. Optional. No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 80>
]

{ #category : #all }
Context >> sender [
	"Answer the context that sent the message that created the receiver."

	^ sender
]

{ #category : #all }
Context >> tempAt: index [
	"Answer the value of the temporary variable whose index is the
	 argument, index.  Primitive. Assumes receiver is indexable. Answer the
	 value of an indexable element in the receiver. Fail if the argument index
	 is not an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default at: primitive to give latitude to the
	 VM in context management."

	<primitive: 210>
	^ self at: index
]

{ #category : #all }
Context >> tempAt: index put: value [
	"Store the argument, value, as the temporary variable whose index is the
	 argument, index.  Primitive. Assumes receiver is indexable. Answer the
	 value of an indexable element in the receiver. Fail if the argument index
	 is not an Integer or is out of bounds. Essential. See Object documentation
	 whatIsAPrimitive.  Override the default at:put: primitive to give latitude to
	 the VM in context management."

	<primitive: 211>
	^ self at: index put: value
]

{ #category : #all }
Context >> canHandleSignal: exception [
	"Sent to handler (on:do:) contexts only.  If my exception class (first arg) handles exception then return true, otherwise forward this message to the next handler context.  If none left, return false (see nil>>canHandleSignal:)"

	^ (self exceptionClass handles: exception)
		or: [ self nextHandlerContext canHandleSignal: exception ]
]

{ #category : #all }
Context >> cannotReturn: result [
	self crError: 'Cannot return, computation has been terminated'.
	self terminate
]

{ #category : #all }
Context >> cannotReturn: result to: aContext [
	self crError: 'Cannot return, computation has been terminated'.
	self terminate
]

{ #category : #all }
Context >> evaluateSignal: exception [
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
Context >> findContextSuchThat: testBlock [
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
Context >> findNextHandlerContext [
	"Return the next handler marked context, returning nil if there is none.  Search starts with self and proceeds up to nil."

	| context searchStartContext |
	context := self findNextHandlerOrSignalingContext.
	context ifNil: [ ^ nil ].
	context isHandlerContext ifTrue: [ ^ context ].
	"If it isn't a handler context, it must be a signaling context.
	When we reach a signaling context we must skip over any handlers
	that might be on the stack between the signaling context and the handler
	context for that signal."
	searchStartContext := context exception privHandlerContext ifNil: [ context ].
	^ searchStartContext nextHandlerContext
]

{ #category : #all }
Context >> findNextHandlerOrSignalingContext [
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
Context >> findNextUnwindContextUpTo: aContext [
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
Context >> handleSignal: exception [
	"Sent to handler (on:do:) contexts only.  If my exception class (first arg) handles exception then execute my handle block (second arg), otherwise forward this message to the next handler context.  If none left, execute exception's defaultAction (see nil>>handleSignal:)."

	(self exceptionClass handles: exception)
		ifFalse: [ ^ self nextHandlerContext handleSignal: exception ].
	self evaluateSignal: exception
]

{ #category : #all }
Context >> nextHandlerContext [

	^ self sender findNextHandlerContext
]

{ #category : #all }
Context >> isDead [
	"Has self finished"

	^ pc isNil
]

{ #category : #all }
Context >> resume: value [
	"Unwind thisContext to self and resume with value as result of last send.  Execute unwind blocks when unwinding.  ASSUMES self is a sender of thisContext"

	self resume: value through: (thisContext findNextUnwindContextUpTo: self)
]

{ #category : #all }
Context >> resume: value through: firstUnwindContext [
	"Unwind thisContext to self and resume with value as result of last send.
	 Execute any unwind blocks while unwinding.
	 ASSUMES self is a sender of thisContext."

	| context unwindBlock |

	self isDead
		ifTrue: [ ^ self cannotReturn: value to: self ].
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
Context >> return: value [
	"Unwind thisContext to self and return value to self's sender.  Execute any unwind blocks while unwinding.  ASSUMES self is a sender of thisContext"

	sender ifNil: [ ^ self cannotReturn: value to: sender ].
	sender resume: value
]

{ #category : #all }
Context >> hasSender: context [
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
Context >> terminate [
	"Make myself unresumable."

	sender := nil.
	pc := nil.
]

{ #category : #all }
Context >> terminateTo: previousContext [
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
Context >> unwindTo: aContext [

	| context unwindBlock |
	context := self.
	[ (context := context findNextUnwindContextUpTo: aContext) isNil ] whileFalse: [
		(context unwindComplete) ifNil: [
			context unwindComplete: true.
			unwindBlock := context unwindBlock.
			unwindBlock value ]]
]

{ #category : #all }
Context >> unwindBlock [
	"unwindContext only. access temporaries from BlockClosure>>#ensure: and BlockClosure>>#ifCurtailed:"
	^ self tempAt: 1
]

{ #category : #all }
Context >> unwindComplete [
	"unwindContext only. access temporaries from BlockClosure>>#ensure: and BlockClosure>>#ifCurtailed:"
	^ self tempAt: 2
]

{ #category : #all }
Context >> unwindComplete: aBoolean [
	"unwindContext only. access temporaries from BlockClosure>>#ensure: and BlockClosure>>#ifCurtailed:"
	self tempAt: 2 put: aBoolean
]

{ #category : #all }
Context >> exception [
	"signaling context (Context>>evaluateSignal:) only. Access the exception argument."
	^ self tempAt: 1
]

{ #category : #all }
Context >> exceptionClass [
	"handlercontext only. access temporaries from BlockClosure>>#on:do:"
	^ self tempAt: 1
]

{ #category : #all }
Context >> exceptionHandlerBlock [
	"handlercontext only. access temporaries from BlockClosure>>#on:do:"
	^ self tempAt: 2
]

{ #category : #all }
Context >> return: value through: firstUnwindContext [
	"Unwind thisContext to self and return value to self's sender.
	 Execute any unwind blocks while unwinding.
	 ASSUMES self is a sender of thisContext."

	sender ifNil: [ ^ self cannotReturn: value to: sender ].
	sender resume: value through: firstUnwindContext
]

{ #category : #all }
Context >> asContext [
	^ self
]

{ #category : #all }
Context >> home [
	"Answer the context in which the receiver was defined."

	closureOrNil == nil
		ifTrue: [ ^ self ].
	^ closureOrNil outerContext home
]

{ #category : #all }
Context >> methodReturnContext [
	"Answer the context from which an ^-return should return from."

	closureOrNil == nil
		ifTrue: [ ^ self ].
	^ closureOrNil outerContext methodReturnContext
]

{ #category : #all }
Context >> method [
	^ method
]

{ #category : #all }
Context >> receiver [
	^ receiver
]

{ #category : #all }
Context >> privRefresh [
	"Reinitialize the receiver so that it is in the state it was at its creation."

	closureOrNil
		ifNotNil: [ pc := closureOrNil startpc.
			self stackp: closureOrNil numTemps.
			1 to: closureOrNil numCopiedValues do:
				[ :i | self tempAt: closureOrNil numArgs + i put: (closureOrNil at: i) ].
			closureOrNil clearTemporariesOn: self ]
		ifNil: [ pc := method initialPC.
			self stackp: method numTemps.
			method numArgs + 1 to: method numTemps do: [ :i | self tempAt: i put: nil ] ]
]

{ #category : #all }
Context >> removeSelf [
	"Nil the receiver pointer and answer its former value."

	| result |
	result := receiver.
	receiver := nil.
	^ result
]

{ #category : #all }
Context >> setSender: s receiver: r method: m closure: c startpc: startpc [
	"Create the receiver's initial state."

	sender := s.
	receiver := r.
	method := m.
	closureOrNil := c.
	pc := startpc.
	stackp := 0
]

{ #category : #all }
Context >> stackp: newStackp [
	"Storing into the stack pointer is a potentially dangerous thing.
	This primitive stores nil into any cells that become accessible as a result,
	and it performs the entire operation atomically."

	"Once this primitive is implemented, failure code should cause an error"

	<primitive: 76>
	self error: 'stackp store failure'
]

{ #category : #all }
Context >> isHandlerContext [
	"is this context for #on:do:?"
	^ self isHandlerOrSignalingContext and: [ method selector == #on:do: ]
]

{ #category : #all }
Context >> isHandlerOrSignalingContext [
	"Both BlockClosure>>on:do: (handler) and Context>>evaluateSignal: (signaling)
	are marked with primitive 199."
	^ method primitive = 199
]

{ #category : #all }
Context >> isUnwindContext [
	"is this context for  method that is marked?"
	^ method primitive = 198
]

{ #category : #all }
Context >> aboutToReturn: result through: firstUnwindContext  [
	"Called from VM when an unwindBlock is found between self and its home.
	 Return to home's sender, executing unwind blocks on the way."

	self methodReturnContext return: result through: firstUnwindContext
]

{ #category : #all }
Context >> printOn: aStream [
	"A quick way to show some context"

	receiver class printOn: aStream.
	method
		ifNotNil: [
			"Print (implementation class and) method"
			receiver class == method methodClass
				ifFalse: [
					aStream nextPut: $(.
					method methodClass printOn: aStream.
					aStream nextPut: $) ].
			aStream nextPutAll: ' >> '.
			self method selector printOn: aStream.

			"Print arguments (if no closure)"
			closureOrNil ifNil: [
				1 to: self method numArgs do: [ :i |
					aStream nextPutAll: (i > 1 ifTrue: [ ', ' ] ifFalse: [ ' ' ]).
					(self argAt: i) printOn: aStream ] ] ]
		ifNil: [ aStream nextPutAll: ' >> <unknown method>' ].

	closureOrNil
		ifNotNil: [
			aStream nextPutAll: ' []' ].

	aStream	nextPut: Character lf.
	sender ifNotNil: [
		aStream nextPutAll: 'Called from: '.
		sender printOn: aStream ]
]

{ #category : #all }
Context >> argAt: index [
	<primitive: 210>
	^ nil
]
