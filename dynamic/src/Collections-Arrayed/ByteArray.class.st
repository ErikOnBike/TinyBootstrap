Class {
	#name : #ByteArray,
	#superclass : #ArrayedCollection,
	#type : #bytes,
	#category : #'Collections-Arrayed'
}

{ #category : #all }
ByteArray >> asByteArray [
	^ self
]

{ #category : #all }
ByteArray >> asString [
	"Answer the receiver converted to a String."

	^ (String new: self size)
		replaceFrom: 1
		to: self size
		with: self
		startingAt: 1
]

{ #category : #all }
ByteArray >> replaceFrom: startIndex to: stopIndex with: source startingAt: srcStartIndex [
	"Primitive. Destructively replace the elements from startIndex to stopIndex in the receiver with the elements starting at srcStartIndex in the source collection. Answer the receiver. Range checks are performed in the primitive. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 105>
	super
		replaceFrom: startIndex
		to: stopIndex
		with: source
		startingAt: srcStartIndex
]

{ #category : #all }
ByteArray >> byteAt: index [
	<primitive: 60>
	^self at: index
]

{ #category : #all }
ByteArray >> byteAt: index put: value [
	<primitive: 61>
	^self at: index put: value
]
