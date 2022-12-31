Class {
	#name : #Message,
	#superclass : #Object,
	#instVars : [
		'selector',
		'arguments',
		'lookupClass'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
Message class >> selector: aSymbol [
	^ self new setSelector: aSymbol arguments: (Array new: 0)
]

{ #category : #all }
Message class >> selector: aSymbol arguments: anArray [
	^ self new setSelector: aSymbol arguments: anArray
]

{ #category : #all }
Message >> arguments [
	"Answer the message arguments array."

	^ arguments
]

{ #category : #all }
Message >> lookupClass [
	"Answer the message lookupClass."

	^ lookupClass
]

{ #category : #all }
Message >> printOn: aStream [
	"Refer to the comment in Object|printOn:."

	super printOn: aStream.
	aStream
		nextPutAll: ' selector: ' , selector printString;
		nextPutAll: ' args: ' , arguments printString
]

{ #category : #all }
Message >> selector [
	"Answer the message selector."

	^ selector
]

{ #category : #all }
Message >> sentTo: anObject [
	"Answer the result of sending this message to the given object."

	lookupClass == nil
		ifTrue: [ ^ anObject perform: selector withArguments: arguments ]
		ifFalse: [ ^ anObject
				perform: selector
				withArguments: arguments
				inSuperclass: lookupClass ]
]

{ #category : #all }
Message >> sendTo: anObject [
	anObject perform: selector withArguments: arguments
]

{ #category : #all }
Message >> setSelector: aSymbol [

	selector := aSymbol
]

{ #category : #all }
Message >> setSelector: aSymbol arguments: anArray [

	selector := aSymbol.
	arguments := anArray
]
