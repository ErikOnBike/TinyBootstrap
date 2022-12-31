Class {
	#name : #Error,
	#superclass : #Exception,
	#category : #'Kernel-Exceptions'
}

{ #category : #all }
Error >> defaultAction [
	"No one has handled this error, but now give them a chance to decide how to debug it.  If none handle this either then open debugger (see UnhandedError-defaultAction)"

	UnhandledError signalForException: self
]

{ #category : #all }
Error >> isResumable [
	"Determine whether an exception is resumable."

	^ false
]
