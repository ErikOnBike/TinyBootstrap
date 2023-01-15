Class {
	#name : #ExceptionSet,
	#superclass : #Object,
	#instVars : [
		'exceptions'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #all }
ExceptionSet >> , anException [
	"Return an exception set that contains the receiver and the argument exception. This is commonly used to specify a set of exception selectors for an exception handler."

	self add: anException
]

{ #category : #all }
ExceptionSet >> - anotherException [
	"Create an exception set containnig the receiver
	and anotherException as an exclusion."

	^ ExceptionSetWithExclusions new
		add: self;
		addExclusion: anotherException;
		yourself
]

{ #category : #all }
ExceptionSet >> add: anException [
	"Add anException to the exceptions that I handle"
	
	^ exceptions add: anException
]

{ #category : #all }
ExceptionSet >> handles: anException [
	"Determine whether an exception handler will accept a signaled exception."

	^ exceptions anySatisfy: [ :exception | exception handles: anException ]
]

{ #category : #all }
ExceptionSet >> initialize [

	super initialize.
	exceptions := OrderedCollection new
]
