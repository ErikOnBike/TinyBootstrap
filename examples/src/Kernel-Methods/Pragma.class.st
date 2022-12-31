Class {
	#name : #Pragma,
	#superclass : #Object,
	#instVars : [
		'method',
		'keyword',
		'arguments'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
Pragma class >> keyword: aSymbol arguments: anArray [ 
	^ self new
		keyword: aSymbol;
		arguments: anArray;
		yourself
]

{ #category : #all }
Pragma class >> withPragmasIn: aClass do: aBlock [
	aClass selectorAndMethodsDo: [ :selector :method | method pragmas do: aBlock ]
]

{ #category : #all }
Pragma >> keyword: aSymbol [
	keyword := aSymbol
]

{ #category : #all }
Pragma >> arguments: anArray [
	arguments := anArray
]

{ #category : #all }
Pragma >> argumentAt: index [
	^ self arguments at: index
]

{ #category : #all }
Pragma >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #all }
Pragma >> keyword [
	^ keyword
]

{ #category : #all }
Pragma >> arguments [
	^ arguments
]

{ #category : #all }
Pragma >> numArgs [
	^ arguments size
]

{ #category : #all }
Pragma >> method [
	^ method
]

{ #category : #all }
Pragma >> selector [
	^ method selector
]

{ #category : #all }
Pragma >> methodSelector [
	^ method selector
]

{ #category : #all }
Pragma >> key [
	^ self keyword
]

{ #category : #all }
Pragma >> message [
	^ Message selector: self keyword arguments: self arguments
]

{ #category : #all }
Pragma >> printOn: aStream [
	"Refer to the comment in Object|printOn:."

	super printOn: aStream.
	aStream
		nextPutAll: ' keyword: ' , keyword printString ;
		nextPutAll: ' args: ' , arguments printString
]

{ #category : #all }
Pragma >> = anObject [
	^ self class == anObject class
	  and: [ keyword == anObject keyword
	  and: [ arguments = anObject arguments ] ]
]

{ #category : #all }
Pragma >> hash [
	^ keyword hash + arguments hash
]
