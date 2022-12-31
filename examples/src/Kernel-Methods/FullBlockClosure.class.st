Class {
	#name : #FullBlockClosure,
	#superclass : #BlockClosure,
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
