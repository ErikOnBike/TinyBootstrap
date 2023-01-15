Class {
	#name : #ValueLink,
	#superclass : #Object,
	#instVars : [
		'nextLink',
		'value'
	],
	#category : #'Collections-Support'
}

{ #category : #all }
ValueLink class >> value: aValue [
	^ self new value: aValue
]

{ #category : #all }
ValueLink >> = anotherObject [
	^ self species == anotherObject species
		and: [ self value = anotherObject value
				and: [ self nextLink == anotherObject nextLink ] ]
]

{ #category : #all }
ValueLink >> asLink [
	^ self
]

{ #category : #all }
ValueLink >> hash [
	^ self value hash bitXor: nextLink identityHash
]

{ #category : #all }
ValueLink >> nextLink [
	^ nextLink
]

{ #category : #all }
ValueLink >> nextLink: aLink [
	nextLink := aLink
]

{ #category : #all }
ValueLink >> printOn: aStream [
	aStream nextPutAll: 'ValueLink('.
	value printOn: aStream.
	aStream nextPut: $)
]

{ #category : #all }
ValueLink >> value [
	^ value
]

{ #category : #all }
ValueLink >> value: aValue [
	value := aValue
]
