Class {
	#name : #Association,
	#superclass : #Magnitude,
	#instVars : [
		'key',
		'value'
	],
	#category : #'Collections-Support'
}

{ #category : #all }
Association class >> key: newKey value: newValue [
	"Answer a new Association with the given key and value."

	^ self new key: newKey value: newValue
]

{ #category : #all }
Association >> < aLookupKey [
	"Sort by keys."

	^ key < aLookupKey key
]

{ #category : #all }
Association >> = anAssociation [
	"True if the receiver and argument have equal keys."

	self species = anAssociation species
		ifTrue: [ ^ key = anAssociation key ]
		ifFalse: [ ^ false ]
]

{ #category : #all }
Association >> hash [
	"Hash is reimplemented because = is implemented."

	^ key hash
]

{ #category : #all }
Association >> key [
	^ key
]

{ #category : #all }
Association >> key: anObject [
	key := anObject
]

{ #category : #all }
Association >> key: aKey value: anObject [
	key := aKey.
	value := anObject
]

{ #category : #all }
Association >> printOn: aStream [
	"Print in the format (key->value)."

	aStream nextPut: $(.
	key printOn: aStream.
	aStream nextPutAll: '->'.
	value printOn: aStream.
	aStream nextPut: $)
]

{ #category : #all }
Association >> value [
	^ value
]

{ #category : #all }
Association >> value: anObject [
	value := anObject
]
