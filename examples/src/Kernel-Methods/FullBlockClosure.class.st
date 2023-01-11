Class {
	#name : #FullBlockClosure,
	#superclass : #BlockClosure,
	#type : #variable,
	#instVars : [
		'receiver'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
FullBlockClosure >> receiver [
	^ receiver
]

{ #category : #all }
FullBlockClosure >> receiver: anObject [
	receiver := anObject
]
