Class {
	#name : #MessageNotUnderstood,
	#superclass : #Error,
	#instVars : [
		'message',
		'receiver',
		'reachedDefaultHandler'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #all }
MessageNotUnderstood >> defaultAction [

	reachedDefaultHandler := true.
	super defaultAction.
]

{ #category : #all }
MessageNotUnderstood >> initialize [

	super initialize.
	reachedDefaultHandler := false	
]

{ #category : #all }
MessageNotUnderstood >> isResumable [
	"Determine whether an exception is resumable."

	^true
]

{ #category : #all }
MessageNotUnderstood >> message [
	"Answer the selector and arguments of the message that failed."

	^message
]

{ #category : #all }
MessageNotUnderstood >> message: aMessage [
	message := aMessage
]

{ #category : #all }
MessageNotUnderstood >> messageText [
	"Return an exception's message text."
	
	^ messageText 
			ifNil:
				[message 
					ifNil: [super messageText]
					ifNotNil: [
						message lookupClass == UndefinedObject
							ifTrue: ['receiver of "', message selector printString, '" is nil']
							ifFalse: [message lookupClass printString, ' >> ', message selector printString]]]
]

{ #category : #all }
MessageNotUnderstood >> reachedDefaultHandler [
	^reachedDefaultHandler
]

{ #category : #all }
MessageNotUnderstood >> receiver [
	"Answer the receiver that did not understand the message"

	^ receiver
]

{ #category : #all }
MessageNotUnderstood >> receiver: obj [
	receiver := obj
]

{ #category : #all }
MessageNotUnderstood >> printOn: aStream [
	aStream
		nextPutAll: 'MessageNotUnderstood(#' ;
		nextPutAll: self message selector ;
		nextPutAll: ' by '.
	self receiver printOn: aStream.
	aStream nextPut: $)
]
