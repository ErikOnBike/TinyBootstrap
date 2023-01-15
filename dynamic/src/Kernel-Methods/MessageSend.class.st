Class {
	#name : #MessageSend,
	#superclass : #Object,
	#instVars : [
		'receiver',
		'selector',
		'arguments'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
MessageSend class >> message: aMessage to: anObject [
	^ self receiver: anObject selector: aMessage selector arguments: aMessage arguments
]

{ #category : #all }
MessageSend class >> receiver: anObject selector: aSymbol [
	^ self receiver: anObject selector: aSymbol arguments: #()
]

{ #category : #all }
MessageSend class >> receiver: anObject selector: aSymbol argument: aParameter [
	^ self receiver: anObject selector: aSymbol arguments: (Array with: aParameter)
]

{ #category : #all }
MessageSend class >> receiver: anObject selector: aSymbol arguments: anArray [
	^ self new
		receiver: anObject;
		selector: aSymbol;
		arguments: anArray
]

{ #category : #all }
MessageSend >> = anObject [
	^ anObject species == self species 
		and: [receiver == anObject receiver
		and: [selector == anObject selector
		and: [arguments = anObject arguments]]]
]

{ #category : #all }
MessageSend >> arguments [
	^ arguments
]

{ #category : #all }
MessageSend >> arguments: anArray [
	arguments := anArray
]

{ #category : #all }
MessageSend >> collectArguments: anArgArray [
	"Private"

    | staticArgs |
    staticArgs := self arguments.
    ^(anArgArray size = staticArgs size)
        ifTrue: [anArgArray]
        ifFalse:
            [(staticArgs isEmpty
                ifTrue: [ staticArgs := Array new: selector numArgs]
                ifFalse: [staticArgs copy] )
                    replaceFrom: 1
                    to: (anArgArray size min: staticArgs size)
                    with: anArgArray
                    startingAt: 1]
]
