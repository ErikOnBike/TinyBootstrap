Class {
	#name : #String,
	#superclass : #ArrayedCollection,
	#classVars: [
		'AsciiOrder',
		'UppercasingTable',
		'LowercasingTable'
	],
	#category : #'Kernel-Text'
}

{ #category : #all }
String class >> initialize [
	"Initialize class variables, the order is important!"

	AsciiOrder := self newAsciiOrder.
	UppercasingTable := self newUppercasingTable.
	LowercasingTable := self newLowercasingTable
]

{ #category : #all }
String class >> newAsciiOrder [
	^ ByteArray withAll: (0 to: 255)
]

{ #category : #all }
String class >> newUppercasingTable [
	"a table for translating to lower case (assume AsciiOrder is set before calling this)"
	| table |
	table := ByteString new: 256.
	(0 to: 255) withIndexDo: [ :each :index |
		table at: index put: (Character value: each) asUppercase ].
	^ table
]

{ #category : #all }
String class >> newLowercasingTable [
	"a table for translating to lower case (assume AsciiOrder is set before calling this)"
	| table |
	table := ByteString new: 256.
	(0 to: 255) withIndexDo: [ :each :index |
		table at: index put: (Character value: each) asLowercase ].
	^ table
]

{ #category : #all }
String class >> new: sizeRequested [
	"Return an instance with the number of indexable variables specified by the argument"

	^ self == String
		ifTrue:[ ByteString new: sizeRequested ]
		ifFalse:[ self basicNew: sizeRequested ]
]

{ #category : #all }
String class >> cr [
	"Answer a string containing a carriage return character"

	^ self with: Character cr
]

{ #category : #all }
String class >> lf [
	"Answer a string containing a linefeed character"

	^ self with: Character lf
]

{ #category : #all }
String class >> with: aCharacter [
	"Answer a string containing the specified character"

	^ ((aCharacter asInteger < 256 ifTrue: [ ByteString ] ifFalse: [ WideString ]) new: 1)
		at: 1 put: aCharacter ;
		yourself
]

{ #category : #all }
String class >> stringHash: aString initialHash: speciesHash [
	| stringSize hash low |
	stringSize := aString size.
	hash := speciesHash bitAnd: 16rFFFFFFF.
	1 to: stringSize do: [:pos |
		hash := hash + (aString basicAt: pos).
		"Begin hashMultiply"
		low := hash bitAnd: 16383.
		hash := (16r260D * low + ((16r260D * (hash // 16384) + (16r0065 * low) bitAnd: 16383) * 16384)) bitAnd: 16r0FFFFFFF.
	].
	^ hash
]

{ #category : #all }
String class >> translate: aString from: start  to: stop  table: table [
	"Trivial, non-primitive version"
	| char |
	start to: stop do: [:i |
		(char := aString basicAt: i) < 256 ifTrue: [
			aString at: i put: (table at: char+1)].
	]
]

{ #category : #all }
String class >> compare: string1 with: string2 collated: order [
	"Return 1, 2 or 3, if string1 is <, =, or > string2, with the collating order of characters given by the order array."

	| len1 len2 c1 c2 |
	order ifNil: [
		len1 := string1 size.
		len2 := string2 size.
		1 to: (len1 min: len2) do:[:i |
			c1 := (string1 basicAt: i).
			c2 := (string2 basicAt: i).
			c1 = c2 ifFalse: [c1 < c2 ifTrue: [^ 1] ifFalse: [^ 3]].
		].
		len1 = len2 ifTrue: [^ 2].
		len1 < len2 ifTrue: [^ 1] ifFalse: [^ 3].
	].
	len1 := string1 size.
	len2 := string2 size.
	1 to: (len1 min: len2) do:[:i |
		c1 := (string1 basicAt: i).
		c2 := (string2 basicAt: i).
		c1 < 256 ifTrue: [c1 := order at: c1 + 1].
		c2 < 256 ifTrue: [c2 := order at: c2 + 1].
		c1 = c2 ifFalse:[c1 < c2 ifTrue: [^ 1] ifFalse: [^ 3]].
	].
	len1 = len2 ifTrue: [^ 2].
	len1 < len2 ifTrue: [^ 1] ifFalse: [^ 3]
]

{ #category : #all }
String >> < aString [
	"Answer whether the receiver sorts before aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) = 1
]

{ #category : #all }
String >> <= aString [
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) <= 2
]

{ #category : #all }
String >> = aString [
	"Answer whether the receiver sorts equally as aString.
	The collation order is simple ascii (with case differences)."

	(aString isString and: [self size = aString size]) ifFalse: [^false].
	^ (self compare: self with: aString collated: AsciiOrder) = 2
]

{ #category : #all }
String >> > aString [
	"Answer whether the receiver sorts after aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) = 3
]

{ #category : #all }
String >> >= aString [
	"Answer whether the receiver sorts after or equal to aString.
	The collation order is simple ascii (with case differences)."

	^ (self compare: self with: aString collated: AsciiOrder) >= 2
]

{ #category : #all }
String >> compare: string1 with: string2 collated: order [
	
	^ (string1 isByteString and: [string2 isByteString])
		ifTrue: [ ByteString compare: string1 with: string2 collated: order ]
		ifFalse: [ String compare: string1 with: string2 collated: order ]
]

{ #category : #all }
String >> asUppercase [
	"Answer a String made up from the receiver whose characters are all uppercase."

	^ self copy asString translateToUppercase
]

{ #category : #all }
String >> asLowercase [
	"Answer a String made up from the receiver whose characters are all uppercase."

	^ self copy asString translateToLowercase
]

{ #category : #all }
String >> asString [
	"Answer this string."

	^ self
]

{ #category : #all }
String >> asNumber [
	"Answer the Number created by interpreting the receiver as the string 
	representation of a number"

	^ Number readFrom: self
]

{ #category : #all }
String >> asNumberOrNil [
	"Answer the Number created by interpreting the receiver as the string 
	representation of a number. Used internally only (since no rigorous testing)."

	(self isNotEmpty and: [ self first isDigit ])
		ifTrue: [ ^ self asNumber ].
	^ nil
]

{ #category : #all }
String >> translateToUppercase [
	"Translate all characters to lowercase, in place"

	self translateWith: UppercasingTable
]

{ #category : #all }
String >> translateToLowercase [
	"Translate all characters to lowercase, in place"

	self translateWith: LowercasingTable
]

{ #category : #all }
String >> translateWith: table [
	"translate the characters in the string by the given table, in place"
	^ self translateFrom: 1 to: self size table: table
]

{ #category : #all }
String >> translateFrom: start  to: stop  table: table [
	"translate the characters in the string by the given table, in place"
	self class translate: self from: start to: stop table: table
]

{ #category : #all }
String >> at: index [
	"Primitive. Answer the Character stored in the field of the receiver
	indexed by the argument. Fail if the index argument is not an Integer or
	is out of bounds. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 63>
	self primitiveFailed
]

{ #category : #all }
String >> at: index put: aCharacter [
	"Primitive. Store the Character in the field of the receiver indicated by
	the index. Fail if the index is not an Integer or is out of bounds, or if
	the argument is not a Character. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 64>
	self primitiveFailed
]

{ #category : #all }
String >> isString [
	^ true
]

{ #category : #all }
String >> printOn: aStream [
	"Print inside string quotes, doubling inbedded quotes."

	| x |
	aStream nextPut: $'.
	1 to: self size do: [ :i | 
		aStream nextPut: (x := self at: i).
		x == $'
			ifTrue: [ aStream nextPut: x ] ].
	aStream nextPut: $'
]

{ #category : #all }
String >> replaceFrom: start to: stop with: replacement startingAt: repStart [
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 105>
	super
		replaceFrom: start
		to: stop
		with: replacement
		startingAt: repStart
]

{ #category : #all }
String >> size [
	"Primitive. Answer the number of indexable fields in the receiver. This
	value is the same as the largest legal subscript. Essential. See Object
	documentation whatIsAPrimitive."

	<primitive: 62>
	^ self basicSize
]

{ #category : #all }
String >> truncateTo: smallSize [
	"return myself or a copy shortened to smallSize."

	^ self size <= smallSize
		ifTrue: [ self ]
		ifFalse: [ self copyFrom: 1 to: smallSize ]
]

{ #category : #all }
String >> withoutSuffix: suffix [
	"Remove the given suffix, if present."

	^ (self endsWith: suffix)
		ifTrue: [ self copyFrom: 1 to: self size - suffix size ]
		ifFalse: [ self ]
]

{ #category : #all }
String >> format: aCollection [
	"Format the receiver by interpolating elements from collection, as in the following examples:"
	"('Five is {1}.' format: { 1 + 4}) >>> 'Five is 5.'"
	"('Five is {five}.' format: (Dictionary with: #five -> 5)) >>>  'Five is 5.'"
	"('In {1} you can escape \{ by prefixing it with \\' format: {'strings'}) >>> 'In strings you can escape { by prefixing it with \' "
	"('In \{1} you can escape \{ by prefixing it with \\' format: {'strings'}) >>> 'In {1} you can escape { by prefixing it with \' "

	^ self class
		new: self size
		streamContents: [ :result |
			| stream |
			stream := self readStream.
			[ stream atEnd ]
				whileFalse: [ | currentChar |
					(currentChar := stream next) == ${
						ifTrue: [ | expression index |
							expression := stream upTo: $}.
							index := expression asNumberOrNil ifNil: [ expression ].
							result nextPutAll: (aCollection at: index) asString ]
						ifFalse: [ currentChar == $\
								ifTrue: [ stream atEnd
										ifFalse: [ result nextPut: stream next ] ]
								ifFalse: [ result nextPut: currentChar ] ] ] ]
]

{ #category : #all }
String >> hash [

	^ self class stringHash: self initialHash: ByteString hash
]
