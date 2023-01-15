Class {
	#name : #Interval,
	#superclass : #SequenceableCollection,
	#instVars : [
		'start',
		'stop',
		'step'
	],
	#category : #'Collections-Sequenceable'
}

{ #category : #all }
Interval class >> streamSpecies [
	^ Array
]

{ #category : #all }
Interval class >> from: startInteger to: stopInteger [
	"Answer an instance of me, starting at startNumber, ending at stopNumber, and with an interval increment of 1."

	^ self basicNew setFrom: startInteger to: stopInteger by: 1
]

{ #category : #all }
Interval class >> from: startInteger to: stopInteger by: stepInteger [
	"Answer an instance of me, starting at startNumber, ending at stopNumber, and with an interval increment of stepNumber."

	^ self basicNew setFrom: startInteger to: stopInteger by: stepInteger
]

{ #category : #all }
Interval >> = anInterval [
	"Answer true if my species and anInterval species are equal, and
	if our starts, steps and sizes are equal."

	self species == anInterval species
		ifTrue: [ ^ start = anInterval first
				and: [ step = anInterval increment and: [ self size = anInterval size ] ] ]
		ifFalse: [ ^ false ]
]

{ #category : #all }
Interval >> add: newObject [
	"Adding to an Interval is not allowed."

	self shouldNotImplement
]

{ #category : #all }
Interval >> at: anInteger [
	"Answer the anInteger'th element."

	(anInteger >= 1 and: [ anInteger <= self size ])
		ifTrue: [ ^ start + (step * (anInteger - 1)) ]
		ifFalse: [ self errorSubscriptBounds: anInteger ]
]

{ #category : #all }
Interval >> at: anInteger put: anObject [
	"Storing into an Interval is not allowed."

	self error: 'you can not store into an interval'
]

{ #category : #all }
Interval >> collect: aBlock [
	| nextValue result |
	result := self species new: self size.
	nextValue := start.
	1 to: result size do: [ :i | 
		result at: i put: (aBlock value: nextValue).
		nextValue := nextValue + step ].
	^ result
]

{ #category : #all }
Interval >> do: aBlock [
	| aValue |
	aValue := start.
	step < 0
		ifTrue: [ [ stop <= aValue ]
				whileTrue: [ aBlock value: aValue.
					aValue := aValue + step ] ]
		ifFalse: [ [ stop >= aValue ]
				whileTrue: [ aBlock value: aValue.
					aValue := aValue + step ] ]
]

{ #category : #all }
Interval >> first [
	"Refer to the comment in SequenceableCollection|first."

	^ start
]

{ #category : #all }
Interval >> hash [
	"Hash is reimplemented because = is implemented."

	^ (((start hash bitShift: 2) bitOr: stop hash) bitShift: 1)
		bitOr: self size
]

{ #category : #all }
Interval >> includes: aNumber [
	^ aNumber between: self first and: self last
]

{ #category : #all }
Interval >> increment [
	"Answer the receiver's interval increment."

	^ step
]

{ #category : #all }
Interval >> last [
	"Refer to the comment in SequenceableCollection|last."

	^ stop - ((stop - start) \\ step)
]

{ #category : #all }
Interval >> printOn: aStream [
	aStream nextPut: $(.
	start printOn: aStream.
	aStream nextPutAll: ' to: '.
	stop printOn: aStream.
	step ~= 1
		ifTrue: [ aStream nextPutAll: ' by: '.
			step printOn: aStream ].
	aStream nextPut: $)
]

{ #category : #all }
Interval >> remove: newObject [
	"Removing from an Interval is not allowed."

	self error: 'elements cannot be removed from an Interval'
]

{ #category : #all }
Interval >> setFrom: startInteger to: stopInteger by: stepInteger [
	start := startInteger.
	stop := stopInteger.
	step := stepInteger
]

{ #category : #all }
Interval >> size [
	step < 0
		ifTrue: [ start < stop
				ifTrue: [ ^ 0 ]
				ifFalse: [ ^ (stop - start) // step + 1 ] ]
		ifFalse: [ stop < start
				ifTrue: [ ^ 0 ]
				ifFalse: [ ^ (stop - start) // step + 1 ] ]
]

{ #category : #all }
Interval >> species [
	^ Array
]
