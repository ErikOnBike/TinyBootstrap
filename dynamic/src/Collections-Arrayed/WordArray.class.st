Class {
	#name : #WordArray,
	#superclass : #ArrayedCollection,
	#type : #words,
	#category : #'Collections-Arrayed'
}

{ #category : #all }
WordArray >> replaceFrom: startIndex to: stopIndex with: source startingAt: srcStartIndex [
	"Primitive. Destructively replace the elements from startIndex to stopIndex in the receiver with the elements starting at srcStartIndex in the source collection. Answer the receiver. Range checks are performed in the primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 105>
	super
		replaceFrom: startIndex
		to: stopIndex
		with: source
		startingAt: srcStartIndex
]
