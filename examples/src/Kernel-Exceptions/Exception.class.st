Class {
	#name : #Exception,
	#superclass : #Object,
	#instVars : [
		'messageText',
		'tag',
		'signaler',
		'signalContext',
		'handlerContext',
		'outerContext'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #all }
Exception class >> , anotherException [
	"Create an exception set containing the receiver and anotherException"

	^ ExceptionSet new
		add: self;
		add: anotherException;
		yourself
]

{ #category : #all }
Exception class >> - anotherException [
	"Create an exception set containing the receiver and anotherException as exclusion."

	^ ExceptionSetWithExclusions new
		add: self;
		addExclusion: anotherException;
		yourself
]

{ #category : #all }
Exception class >> handles: exception [
	"Determine whether an exception handler will accept a signaled exception."

	^ exception isKindOf: self
]

{ #category : #all }
Exception class >> signal [
	"Signal the occurrence of an exceptional condition."

	^ self new signal
]

{ #category : #all }
Exception class >> signal: message [
	"Signal the occurrence of an exceptional condition with a specified textual description."

	^ self new signal: message
]

{ #category : #all }
Exception class >> signal: message in: context [
	"Signal the occurrence of an exceptional condition with a specified textual description in the given context."

	^ self new 
		messageText: message;
		signalIn: context
]

{ #category : #all }
Exception class >> signal: message withTag: aTag [
	"Signal the occurrence of an exceptional condition with a specified textual description including a tag for the exception."

	^ self new 
		messageText: message;
		tag: aTag; 
		signal
]

{ #category : #all }
Exception class >> signalIn: context [
	"Signal the occurrence of an exceptional condition in the given context."

	^ self new signalIn: context
]

{ #category : #all }
Exception >> defaultAction [
	"The default action taken if the exception is signaled."

	self subclassResponsibility
]

{ #category : #all }
Exception >> defaultResumeValue [
	"Answer the value that by default should be returned if the exception is resumed"
	
	^ nil
]

{ #category : #all }
Exception >> defaultReturnValue [
	"Answer the value that by default should be returned if the exception is returned"
	
	^ nil
]

{ #category : #all }
Exception >> description [
	"Return a textual description of the exception."

	^ String streamContents: [ :stream |
		| mt |
		stream nextPutAll: self class name.
		(mt := self messageText) isEmpty
			ifFalse: [
				stream
					nextPutAll: ': ' ;
					nextPutAll: mt ] ]
]

{ #category : #all }
Exception >> isNested [
	"Determine whether the current exception handler is within the scope of another handler for the same exception."

	^ handlerContext nextHandlerContext canHandleSignal: self
]

{ #category : #all }
Exception >> isResumable [
	"Determine whether an exception is resumable."

	^ true
]

{ #category : #all }
Exception >> messageText [
	"Return an exception's message text."

	^ messageText ifNil: [ '' ]
]

{ #category : #all }
Exception >> messageText: signalerText [
	"Set an exception's message text."

	messageText := signalerText
]

{ #category : #all }
Exception >> outer [
	"Evaluate the enclosing exception action and return to here instead of signal if it resumes (see #resumeUnchecked:)."

	| prevOuterContext |
	self isResumable 
		ifTrue: [
			prevOuterContext := outerContext. "required and accessed in resumeUnchecked:"
			outerContext := thisContext ].
	self pass.
]

{ #category : #all }
Exception >> pass [
	"Yield control to the enclosing exception action for the receiver."

	handlerContext nextHandlerContext handleSignal: self
]

{ #category : #all }
Exception >> privHandlerContext [

	^handlerContext
]

{ #category : #all }
Exception >> privHandlerContext: aContextTag [

	handlerContext := aContextTag
]

{ #category : #all }
Exception >> receiver [
	^ self signalerContext receiver
]

{ #category : #all }
Exception >> resignalAs: replacementException [
	"Signal an alternative exception in place of the receiver."
	
	^ replacementException signalIn: signalContext
]

{ #category : #all }
Exception >> resume [
	"Return from the message that signaled the receiver."

	self resume: self defaultResumeValue
]

{ #category : #all }
Exception >> resume: resumptionValue [
	"Return resumptionValue as the value of the signal message."

	self isResumable ifFalse: [ IllegalResumeAttempt signal ].
	self resumeUnchecked: resumptionValue
]

{ #category : #all }
Exception >> resumeUnchecked: resumptionValue [
	"Return resumptionValue as the value of #signal, unless this was called after an #outer message, then return resumptionValue as the value of #outer."

	| ctxt |
	outerContext 
		ifNil: [
			signalContext return: resumptionValue ] 
		ifNotNil: [
			ctxt := outerContext.
			outerContext := ctxt tempAt: 1. "prevOuterContext in #outer"
			ctxt return: resumptionValue ]

]

{ #category : #all }
Exception >> retry [
	"Abort an exception handler and re-evaluate its protected block."

	handlerContext restart
]

{ #category : #all }
Exception >> retryUsing: alternativeBlock [
	"Abort an exception handler and evaluate a new block in place of the handler's protected block."

	handlerContext restartWithNewReceiver: alternativeBlock

]

{ #category : #all }
Exception >> return [
	"Return nil as the value of the block protected by the active exception handler."

	self return: self defaultReturnValue
]

{ #category : #all }
Exception >> return: returnValue [
	"Return the argument as the value of the block protected by the active exception handler."

	handlerContext return: returnValue
]

{ #category : #all }
Exception >> searchFrom: aContext [
	"Set the context where the handler search will start. "

	signalContext := aContext
]

{ #category : #all }
Exception >> signal [
	"Ask ContextHandlers in the sender chain to handle this signal.  The default is to execute and return my defaultAction."
	signalContext := thisContext.
	signaler ifNil: [ signaler := self receiver ].
	^ signalContext nextHandlerContext handleSignal: self
]

{ #category : #all }
Exception >> signal: signalerText [
	"Signal the occurrence of an exceptional condition with a specified textual description."

	self messageText: signalerText.
	^ self signal
]

{ #category : #all }
Exception >> signalIn: context [
	"Ask ContextHandlers in the sender chain starting at the given context to handle this signal. 
	The default is to execute and return my defaultAction."

	signalContext := context.
	signaler ifNil: [ signaler := self receiver ].
	^ signalContext nextHandlerContext handleSignal: self
]

{ #category : #all }
Exception >> signalContext [
	^ signalContext
]

{ #category : #all }
Exception >> signaler [
	"Return the object that is the subject involving me.
	This is set automatically to my #receiver during #signal
	but could be overwritten when I am signaled"

	^ signaler
]

{ #category : #all }
Exception >> signaler: anObject [
	"Set the object that is the subject involving me.
	This is set automatically to my #receiver during #signal
	but could be overwritten when I am signaled"

	signaler := anObject
]

{ #category : #all }
Exception >> signalerContext [
	"Find the first sender of signal(:), the first context which is neither for an instance method nor for a class side method of Exception (or subclass).
	This will make sure that the same context is found for both, `Error signal` and `Error new signal`"

	^ signalContext findContextSuchThat: [ :context |
		(context receiver == self 
		or: [ context receiver == self class ]) not ]
]

{ #category : #all }
Exception >> tag [
	"Return an exception's tag value."

	^ tag 
		ifNil: [ self messageText ]
		ifNotNil: [ tag ]
]

{ #category : #all }
Exception >> tag: t [
	"This message is not specified in the ANSI protocol, but that looks like an oversight because #tag is specified, and the spec states that the signaler may store the tag value."

	tag := t
]
