Class {
	#name : #UndefinedObject,
	#superclass : #Object,
	#category : #'Kernel-Objects'
}

{ #category : #all }
UndefinedObject class >> new [
	"There is a single unique instance of me."

	self cannotInstantiate
]

{ #category : #all }
UndefinedObject >> basicCopy [
	"There is the only one instance of me, so answer myself."

	^ self
]

{ #category : #all }
UndefinedObject >> ifNil: aBlock [
	"A convenient test, in conjunction with Object ifNil:"

	^ aBlock value
]

{ #category : #all }
UndefinedObject >> ifNotNil: ifNotNilBlock ifNil: nilBlock [
	"Evaluate the block for nil because I'm == nil"

	^ nilBlock value
]

{ #category : #all }
UndefinedObject >> ifNil: nilBlock ifNotNil: ifNotNilBlock [
	"Evaluate the block for nil because I'm == nil"

	^ nilBlock value
]

{ #category : #all }
UndefinedObject >> ifNotNil: aBlock [
	"A convenient test, in conjunction with Object ifNotNil:"

	^ self
]

{ #category : #all }
UndefinedObject >> isNil [
	"Answer true if the receiver is nil."

	^ true
]

{ #category : #all }
UndefinedObject >> notNil [
	"Answer true if the receiver is not nil."

	^ false
]

{ #category : #all }
UndefinedObject >> isNotNil [
	"Answer true if the receiver is not nil."

	^ false
]

{ #category : #all }
UndefinedObject >> printOn: aStream [
	aStream nextPutAll: 'nil'
]

{ #category : #all }
UndefinedObject >> subclass: subclassName instanceVariableNames: instVarNames classVariableNames: classVarNames [
	^ ClassBuilder new
		superclass: self;
		name: subclassName;
		instVarNames: instVarNames;
		classVariableNames: classVarNames;
		build
]

{ #category : #all }
UndefinedObject >>  handleSignal: exception [
	"When no more handler (on:do:) context left in sender chain this gets called.  Return from signal with default action."

	^ exception resumeUnchecked: exception defaultAction
]

{ #category : #all }
UndefinedObject >>  canHandleSignal: exception [
	"When no more handler (on:do:) context left in sender chain this gets called"

	^ false
]
