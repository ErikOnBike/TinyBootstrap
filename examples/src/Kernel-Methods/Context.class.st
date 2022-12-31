Class {
	#name : #Context,
	#superclass : #BlockContext,
	#type : #variable,
	#instVars : [
		'method',
		'closureOrNil',
		'receiver'
	],
	#category : #'Kernel-Methods'
}

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
	^self isHandlerOrSignalingContext and: [ method selector == #on:do: ]
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
