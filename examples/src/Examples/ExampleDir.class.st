Class {
	#name : #ExampleDir,
	#superclass : #Object,
	#category : #Examples
}

{ #category : #all }
ExampleDir class >> doIt [

	| index dirEntry |

	"Print all entries in the current directory"
	self crTrace: 'All entries in the current directory:'.

	index := 1.
	[ index isNotNil ] whileTrue: [
		dirEntry := File lookupEntryIn: '.' index: index.
		dirEntry
			ifNotNil: [
				self crTrace: dirEntry printString.
				index := index + 1 ]
			ifNil: [ index := nil ] ].

	Smalltalk quit
]
