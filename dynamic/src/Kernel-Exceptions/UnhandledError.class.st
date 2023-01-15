Class {
	#name : #UnhandledError,
	#superclass : #Exception,
	#instVars : [
		'exception'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #all }
UnhandledError class >> signalForException: anError [

	^ self new
		exception: anError;
		signal
]

{ #category : #all }
UnhandledError >> defaultAction [

	self crError: 'UnhandledError: ', exception printString.
	self crError: 'Quiting'.

	Smalltalk quit
]

{ #category : #all }
UnhandledError >> exception [

	^ exception
]

{ #category : #all }
UnhandledError >> exception: anError [

	exception := anError
]

{ #category : #all }
UnhandledError >> isResumable [
	
	^ false
]
