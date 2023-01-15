Class {
	#name : #Rectangle,
	#superclass : #Object,
	#instVars : [
		'origin',
		'corner'
	],
	#category : #'Graphics-Primitives'
}

{ #category : #all }
Rectangle class >> origin: originPoint corner: cornerPoint [
	^ self basicNew setOrigin: originPoint corner: cornerPoint
]

{ #category : #all }
Rectangle class >> origin: originPoint extent: extentPoint [
	^ self basicNew setOrigin: originPoint corner: originPoint + extentPoint
]

{ #category : #all }
Rectangle >> = aRectangle [

	self == aRectangle ifTrue: [ ^ true ].

	"Answer true if the receiver's species, origin and corner match aRectangle's."
	self species == aRectangle species
		ifFalse: [ ^false ].

	^ origin = aRectangle origin and: [ corner = aRectangle corner ]
]

{ #category : #all }
Rectangle >> origin [
	^ origin
]

{ #category : #all }
Rectangle >> corner [
	^ corner
]

{ #category : #all }
Rectangle >> top [
	^ origin y
]

{ #category : #all }
Rectangle >> bottom [
	^ corner y
]

{ #category : #all }
Rectangle >> left [
	^ origin x
]

{ #category : #all }
Rectangle >> right [
	^ corner x
]

{ #category : #all }
Rectangle >> width [
	^ corner x - origin x
]

{ #category : #all }
Rectangle >> height [
	^ corner y - origin y
]

{ #category : #all }
Rectangle >> isTall [
	^ self height > self width
]

{ #category : #all }
Rectangle >> isWide [
	^ self width > self height
]

{ #category : #all }
Rectangle >> hash [
	"Hash is reimplemented because = is implemented."

	^origin hash bitXor: corner hash
]

{ #category : #all }
Rectangle >> printOn: aStream [
	"Refer to the comment in Object|printOn:."

	origin printOn: aStream.
	aStream nextPutAll: ' corner: '.
	corner printOn: aStream
]
