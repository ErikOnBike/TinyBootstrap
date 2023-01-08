Class {
	#name : #ExampleCounter,
	#superclass : #Object,
	#category : #Examples
}

{ #category : #all }
ExampleCounter class >> doIt [

	| value deltaValue |

	"Print what I am"
	self crTrace: 'I am a counter going from 0 to 10 and back. I increase/decrease 1 on every execution.'.

	value := 0.

	"Forever"
	[ 
		"Decide direction (change at either end)"
		value = 0
			ifTrue: [ deltaValue := 1 ]
			ifFalse: [
				value = 10
					ifTrue: [ deltaValue := -1 ] ].

		"Show current state"
		self crTrace: 'My current value is ', value printString, ' and I am ', (deltaValue > 0 ifTrue: [ 'increasing' ] ifFalse: [ 'decreasing' ]).

		"Go to the next state"
		value := value + deltaValue.

		"Save current state and stop"
		Smalltalk snapshotAndQuit ] repeat
]
