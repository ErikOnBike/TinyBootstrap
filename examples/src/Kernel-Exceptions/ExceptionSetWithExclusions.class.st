Class {
	#name : #ExceptionSetWithExclusions,
	#superclass : #ExceptionSet,
	#instVars : [
		'exclusions'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #all }
ExceptionSetWithExclusions >> - exception [
	"Add exception as an exclusion to me.
	I will explicitely not handle my exclusion exceptions."
	
	self addExclusion: exception
]

{ #category : #all }
ExceptionSetWithExclusions >> addExclusion: exception [
	"Add exception as an exclusion to me.
	I will explicitely not handle my exclusion exceptions."
	
	^ exclusions add: exception
]

{ #category : #all }
ExceptionSetWithExclusions >> handles: exception [
	"Return true when I will handled exception.
	I extend my superclass behavior by explicitely 
	not handling a number of exclusion exceptions."

	^ (super handles: exception) 
			and: [ exclusions noneSatisfy: [ :each | each handles: exception ] ]
]

{ #category : #all }
ExceptionSetWithExclusions >> initialize [

	super initialize.
	exclusions := OrderedCollection new
]
