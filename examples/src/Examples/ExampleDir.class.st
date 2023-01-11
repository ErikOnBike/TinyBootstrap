Class {
	#name : #ExampleDir,
	#superclass : #Object,
	#category : #Examples
}

{ #category : #all }
ExampleDir class >> doIt [

	| directory index dirEntry |

	"Check directory on command line"
	directory := (Smalltalk getSystemAttribute: 2) ifNil: [ '.' ].

	"Print all entries in the specified (or if not specified, the current) directory"
	self crTrace: 'All entries in the directory:'.

	index := 1.
	[ index isNotNil ] whileTrue: [
		dirEntry := [ File lookupEntryIn: directory index: index ] on: Error do: [ self crTrace: 'Specified directory does not exist or is not readable'. nil ].
		dirEntry
			ifNotNil: [
				self crTrace: dirEntry printString.
				index := index + 1 ]
			ifNil: [ index := nil ] ].

	Smalltalk quit
]
