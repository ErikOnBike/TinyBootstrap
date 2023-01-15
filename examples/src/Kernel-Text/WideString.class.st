Class {
	#name : #WideString,
	#superclass : #String,
	#type : #words,
	#category : #'Kernel-Text'
}

{ #category : #all }
WideString >> asSymbol [
	self error: 'WideSymbols are currently not supported'
]

{ #category : #all }
WideString >> isByteString [
	^ false
]
