Class {
	#name : #BlockClosure,
	#superclass : #Object,
	#instVars : [
		'outerContext',
		'startpc',
		'numArgs'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
BlockClosure >> asContext [
	"Create a (Method)Context that is ready to execute self.  Assumes self takes no args (if it does the args will be nil)"

	^ self asContextWithSender: nil
]

{ #category : #all }
BlockClosure >> asContextWithSender: aContext [
	"Inner private support method for evaluation.  Do not use unless you know what you're doing."

	^ (Context newForMethod: self compiledBlock)
		setSender: aContext
			receiver: self receiver
			method: self compiledBlock
			closure: self
			startpc: self startpc;
		privRefresh
]

{ #category : #all }
BlockClosure >> forkAt: priority [

	^ self forkAt: priority name: nil
]

{ #category : #all }
BlockClosure >> forkAt: priority named: aString [

	"Do not answer forked process, because it might not be running yet leading to unexpected behavior accessing it"

	(Process forContext: self asContext priority: priority)
		name: aString ;
		resume.
	^ nil
]

{ #category : #all }
BlockClosure >> home [
	^ outerContext home
]

{ #category : #all }
BlockClosure >> methodReturnContext [
	^ outerContext methodReturnContext
]

{ #category : #all }
BlockClosure >> ifError: errorHandlerBlock [
	"Evaluate the block represented by the receiver. If an error occurs the given handler block is evaluated. The handler block can be either a zero- or two-argument block; if the latter, then the error message and receiver are supplied to it as parameters. Answer the value returned by the handler block if the receiver gets an error."

	"Warning: The receiver should not contain an explicit return since that would leave an obsolete error handler hanging around."

	"Examples:
		[1 whatsUpDoc] ifError: [:err :rcvr | ^ 'huh?'].
		[1 whatsUpDoc] ifError: ['huh'].
		[1 / 0] ifError: [:err :rcvr |
			'division by 0' = err
				ifTrue: [^ Float infinity]
				ifFalse: [self error: err]]
"
	^ self on: Error do: [ :ex |
		errorHandlerBlock cull: ex description cull: ex receiver]
]

{ #category: #all }
BlockClosure >> on: exception do: handlerAction [
	"Evaluate the receiver in the scope of an exception handler.
	The following primitive is just a marker used to find the error handling context. 
	See (Method)Context>>#isHandlerOrSignalingContext. "
	<primitive: 199>  
	^ self value
]

{ #category : #all }
BlockClosure >> method [
	^ self compiledBlock
]

{ #category : #all }
BlockClosure >> numArgs [
	^ numArgs
]

{ #category : #all }
BlockClosure >> numArgs: anInteger [
	numArgs := anInteger
]

{ #category : #all }
BlockClosure >> numCopiedValues [
	"Answer the number of copied values of the receiver.  Since these are
	 stored in the receiver's indexable fields this is the receiver's basic size.
	 Primitive. Answer the number of indexable variables in the receiver. 
	 This value is the same as the largest legal subscript."

	<primitive: 62>
	^ self basicSize
]


{ #category : #all }
BlockClosure >> numTemps [
	"In newer images startpc contains the CompiledBlock"
	^ startpc numTemps
]

{ #category : #all }
BlockClosure >> clearTemporariesOn: aContext [
 
	(self numArgs + self numCopiedValues + 1) to: self numTemps do: [ :anIndex |  
		aContext tempAt: anIndex put: nil ]
]

{ #category : #all }
BlockClosure >> outerContext [
	^ outerContext
]

{ #category : #all }
BlockClosure >> receiver [
	^ outerContext receiver
]

{ #category : #all }
BlockClosure >> startpc [
	"In newer images startpc contains the CompiledBlock"
	^ startpc initialPC
]

{ #category : #all }
BlockClosure >> compiledBlock [
	"In newer images startpc contains the CompiledBlock"
	^ startpc
]

{ #category : #all }
BlockClosure >> value [
	"Evaluate this block without any arguments."

	<primitive: 207>
	^ self valueWithArguments: #()
]

{ #category : #all }
BlockClosure >> value: arg [
	"Evaluate this block with one argument."

	<primitive: 207>
	^ self valueWithArguments: (Array with: arg)
]

{ #category : #all }
BlockClosure >> value: arg1 value: arg2 [
	"Evaluate this block with two arguments."

	<primitive: 207>
	^ self valueWithArguments: (Array with: arg1 with: arg2)
]

{ #category : #all }
BlockClosure >> valueWithArguments: anArray [
	"Primitive. Evaluate the block represented by the receiver. The argument is an Array whose elements are the arguments for the block. Fail if the length of the Array is not the same as the the number of arguments that the block was expecting. Fail if the block is already being executed. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 208>
	anArray size = numArgs
		ifTrue: [ self
				error: 'Attempt to evaluate a block that is already being evaluated.' ]
		ifFalse: [ self
				error: 'This block requires ' , numArgs printString , ' arguments.' ]
]

{ #category : #all }
BlockClosure >> cull: anArg [
	^numArgs = 0 
		ifTrue: [self value]
		ifFalse: [self value: anArg]
]

{ #category : #all }
BlockClosure >> cull: firstArg cull: secondArg [
	^numArgs = 0 
		ifTrue: [self value]
		ifFalse: [
			numArgs = 1
				ifTrue: [ self value: firstArg]
				ifFalse: [ self value: firstArg value: secondArg ] ]
]

{ #category : #all }
BlockClosure >> repeat [
	[ self value. true ] whileTrue
]

{ #category : #all }
BlockClosure >> whileTrue [
	self value ifTrue: [ self whileTrue ]
]

{ #category : #all }
BlockClosure >> whileFalse [
	self value ifFalse: [ self whileFalse ]
]

{ #category : #all }
BlockClosure >> whileTrue: aBlock [
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the argument, aBlock, as long as the value of the receiver is true."

	self value ifTrue: [ aBlock value. self whileTrue: aBlock ].
	^ nil
]

{ #category : #all }
BlockClosure >> whileFalse: aBlock [
	"Ordinarily compiled in-line, and therefore not overridable.
	This is in case the message is sent to other than a literal block.
	Evaluate the argument, aBlock, as long as the value of the receiver is false."

	self value ifFalse: [ aBlock value. self whileFalse: aBlock ].
	^ nil
]

{ #category : #all }
BlockClosure >> ensure: aBlock [
	"Evaluate a termination block after evaluating the receiver, regardless of
	 whether the receiver's evaluation completes.  N.B.  This method is *not*
	 implemented as a primitive.  Primitive 198 always fails.  The VM uses prim
	 198 in a context's method as the mark for an ensure:/ifCurtailed: activation."

	| complete returnValue |
	<primitive: 198>
	returnValue := self valueNoContextSwitch.
	complete ifNil:[
		complete := true.
		aBlock value.
	].
	^ returnValue
]

{ #category : #all }
BlockClosure >> ifCurtailed: aBlock [
	"Evaluate the receiver with an abnormal termination action.
	 Evaluate aBlock only if execution is unwound during execution
	 of the receiver.  If execution of the receiver finishes normally do
	 not evaluate aBlock.  N.B.  This method is *not* implemented as a
	 primitive.  Primitive 198 always fails.  The VM uses prim 198 in a
	 context's method as the mark for an ensure:/ifCurtailed: activation."
	| complete result |
	<primitive: 198>
	result := self valueNoContextSwitch.
	complete := true.
	^result
]

{ #category : #all }
BlockClosure >> valueNoContextSwitch [
	"An exact copy of BlockClosure>>value except that this version will not preempt
	 the current process on block activation if a higher-priority process is runnable.
	 Primitive. Essential."
	<primitive: 209>
	^ self valueWithArguments: #()
]
