Class {
	#name : #ReadStream,
	#superclass : #Object,
	#instVars : [
		'collection',
		'position',
		'readLimit'
	],
	#category : #'Collections-Streams'
}

{ #category : #all }
ReadStream class >> on: aCollection [
	"Answer an instance of me, streaming over the elements of aCollection."

	^ self basicNew on: aCollection
]

{ #category : #all }
ReadStream >> atEnd [
	"Answer whether the receiver can access any more objects."

	^ position >= readLimit
]

{ #category : #all }
ReadStream >> contents [
	"Answer with a copy of my collection from 1 to readLimit."

	^ collection copyFrom: 1 to: readLimit
]

{ #category : #all }
ReadStream >> next [
	"Answer the next object in the Stream represented by the receiver."

	position >= readLimit
		ifTrue: [ ^ nil ]
		ifFalse: [ ^ collection at: (position := position + 1) ]
]

{ #category : #all }
ReadStream >> next: anInteger [
	"Answer a collection containing the next anInteger elements of my collection."

	| end result |
	end := position + anInteger min: readLimit.
	result := collection copyFrom: position + 1 to: end.
	position := end.
	^ result
]

{ #category : #all }
ReadStream >> on: aCollection [
	"Initialize myself for streaming over the given collection."

	collection := aCollection.
	readLimit := aCollection size.
	position := 0
]

{ #category : #all }
ReadStream >> peek [
	"Answer the next object without advancing my position. Answer nil if there are no more elements."

	| result |
	self atEnd
		ifTrue: [ ^ nil ].
	result := self next.
	position := position - 1.
	^ result
]

{ #category : #all }
ReadStream >> peekFor: anObject [
	"If my next element equals the given object, skip it and answer true. Otherwise, answer false and leave my position unchanged."

	| result |
	result := self peek = anObject.
	result
		ifTrue: [ self skip: 1 ].
	^ result
]

{ #category : #all }
ReadStream >> lookAheadAt: index [

	"Answer the element at the specified (delta) position or nil if outside the receiver boundaries."

	| lookPosition |

	lookPosition := position + 1 + index.	"The #position is 0-based"
	(lookPosition < 1 or: [ lookPosition > readLimit ])
		ifTrue: [ ^ nil ].

	^ collection at: lookPosition
]

{ #category : #all }
ReadStream >> upTo: anObject [
	"fast version using indexOf:"
	| start end |

	start := position+1.
	end := collection indexOf: anObject startingAt: start ifAbsent: [ 0 ].

	"not present--return rest of the collection"
	(end = 0 or: [end > readLimit]) ifTrue: [ ^ self upToEnd ].

	"skip to the end and return the data passed over"
	position := end.
	^ collection copyFrom: start to: (end - 1)
]

{ #category : #all }
ReadStream >> upToEnd [
	"Answer a subcollection from the current access position through the last element of the receiver."

	| newStream |
	newStream := WriteStream on: (collection species new: (100 max: readLimit - position)).
	[ self atEnd ] whileFalse: [ newStream nextPut: self next ].
	^ newStream contents
]

{ #category : #all }
ReadStream >> position [
	"Answer the current position of accessing the sequence of objects."

	^ position
]

{ #category : #all }
ReadStream >> position: anInteger [
	"Set my current position to anInteger, as long as anInteger is within bounds. If not, report an error."

	anInteger >= 0 & (anInteger <= readLimit)
		ifTrue: [ position := anInteger asInteger ]
		ifFalse: [ self error: 'Position out of bounds: ' , anInteger printString ]
]

{ #category : #all }
ReadStream >> setFrom: newStart to: newStop [
	position := newStart - 1.
	readLimit := newStop
]

{ #category : #all }
ReadStream >> size [
	"Compatibility with other streams (e.g., FileStream)"

	^ readLimit
]

{ #category : #all }
ReadStream >> skip [
	self skip: 1
]

{ #category : #all }
ReadStream >> skip: anInteger [
	"Set the receiver's position to be the current position+anInteger."

	self position: (position + anInteger min: readLimit)
]
