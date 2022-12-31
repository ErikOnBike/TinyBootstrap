Class {
	#name : #ByteString,
	#superclass : #String,
	#type : #bytes,
	#category : #'Kernel-Text'
}

{ #category : #all }
ByteString class >> compare: string1 with: string2 collated: order [
	"Return 1, 2 or 3, if string1 is <, =, or > string2, with the collating order of characters given by the order array."

	| len1 len2 c1 c2 |
	<primitive: 'primitiveCompareString' module: 'MiscPrimitivePlugin'>
	
	<var: #string1 declareC: 'unsigned char *string1'>
	<var: #string2 declareC: 'unsigned char *string2'>
	<var: #order declareC: 'unsigned char *order'>

	len1 := string1 size.
	len2 := string2 size.
	1 to: (len1 min: len2) do:
		[:i |
		c1 := order at: (string1 basicAt: i) + 1.
		c2 := order at: (string2 basicAt: i) + 1.
		c1 = c2 ifFalse: 
			[c1 < c2 ifTrue: [^ 1] ifFalse: [^ 3]]].
	len1 = len2 ifTrue: [^ 2].
	len1 < len2 ifTrue: [^ 1] ifFalse: [^ 3]
]

{ #category : #all }
ByteString class >> translate: aString from: start  to: stop  table: table [
	"translate the characters in the string by the given table, in place"
	<primitive: 'primitiveTranslateStringWithTable' module: 'MiscPrimitivePlugin'>
	<var: #table  declareC: 'unsigned char *table'>
	<var: #aString  declareC: 'unsigned char *aString'>

	start to: stop do: [ :i |
		aString at: i put: (table at: (aString basicAt: i) + 1) ]
]

{ #category : #all }
ByteString >> asByteArray [
	"Answer a ByteArray containing the ASCII values of my characters. Uses a fast primitive that avoids character conversion."

	^ (ByteArray new: self size)
		replaceFrom: 1
		to: self size
		with: self
]

{ #category : #all }
ByteString >> asSymbol [
	"This is the only place that new Symbols are created. A Symbol is created if and only if there is not already a Symbol with its contents in existance."

	^ Symbol fromString: self
]

{ #category : #all }
ByteString >> at: index put: aCharacter [

	aCharacter asInteger < 256
		ifTrue: [ ^ super at: index put: aCharacter ]
		ifFalse: [
			self becomeForward: (WideString from: self).
			^ self at: index put: aCharacter ]
]
