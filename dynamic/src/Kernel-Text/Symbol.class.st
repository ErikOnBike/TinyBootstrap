Class {
	#name : #Symbol,
	#superclass : #ByteString,
	#type : #bytes,
	#category : #'Kernel-Text'
}

{ #category : #all }
Symbol class >> streamSpecies [
	^ ByteString
]

{ #category : #all }
Symbol class >> new: size [
	"Symbols are unique. You can create a new Symbol from a String using 'asSymbol'."

	self cannotInstantiate
]

{ #category : #all }
Symbol class >> fromString: aString [

	self allInstancesDo: [ :each |
		each = aString
			ifTrue: [ ^ each ] ].

	^ (self basicNew: aString size)
		initFrom: aString ;
		yourself
]

{ #category : #all }
Symbol class >> translate: aString from: start  to: stop  table: table [
	^ ByteString translate: aString from: start  to: stop  table: table
]

{ #category : #all }
Symbol >> initFrom: aString [
	"Warning! Use only to initialize new Symbols. Symbols are assumed to be immutable there after."

	self size = aString size
		ifFalse: [ self error: 'size mismatch' ].
	super
		replaceFrom: 1
		to: self size
		with: aString
		startingAt: 1
]

{ #category : #all }
Symbol >> = aSymbol [
	"Compare the receiver and aSymbol."
	self == aSymbol ifTrue: [ ^ true ].
	self class == aSymbol class ifTrue: [ ^ false ].
	"Use String comparison otherwise"
	^ super = aSymbol
]

{ #category : #all }
Symbol >> isSymbol [
	^ true
]

{ #category : #all }
Symbol >> isLiteralSymbol [
	self ifEmpty: [ ^ false ].
	self first isDigit ifTrue: [ ^ false ].
	self do: [ :each | (each isLetter or: [ each isDigit ]) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #all }
Symbol >> asString [
	"Answer a string containing my characters."

	| sz result |
	sz := self size.
	result := String new: sz.
	result
		replaceFrom: 1
		to: sz
		with: self
		startingAt: 1.
	^ result
]

{ #category : #all }
Symbol >> asSymbol [
	^ self
]

{ #category : #all }
Symbol >> at: anInteger put: anObject [
	"You cannot modify the receiver."

	self errorNoModification
]

{ #category : #all }
Symbol >> basicCopy [
	"Answer myself because Symbols are unique."

	
]

{ #category : #all }
Symbol >> errorNoModification [
	self error: 'Symbols can not be modified.'
]

{ #category : #all }
Symbol >> numArgs [
	"Answer the number of arguments that the receiver would take considered as a selector or -1 if it couldn't be a selector."

	| firstChar numColons |
	firstChar := self at: 1.
	firstChar isLetter
		ifTrue: [ numColons := 0.
			self
				do: [ :ch | 
					ch tokenish
						ifFalse: [ ^ -1 ].
					ch = $:
						ifTrue: [ numColons := numColons + 1 ] ].
			numColons > 0 & (self last ~= $:)
				ifTrue: [ ^ -1 ].
			^ numColons ].
	firstChar isSpecial
		ifTrue: [ self size = 1
				ifTrue: [ ^ 1 ].
			(self size = 2 and: [ (self at: 2) isSpecial ])
				ifTrue: [ ^ 1 ].
			^ -1 ].
	^ -1
]

{ #category : #all }
Symbol >> printOn: aStream [
	aStream nextPut: $#.
	self isLiteralSymbol
		ifTrue: [ aStream nextPutAll: self ]
		ifFalse: [ super printOn: aStream ]
]

{ #category : #all }
Symbol >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	self errorNoModification
]

{ #category : #all }
Symbol >> species [
	^ ByteString
]

{ #category : #all }
Symbol >> flushCache [
	<primitive: 119>
]
