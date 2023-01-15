Class {
	#name : #TtObjectDecoder,
	#superclass : #Object,
	#instVars : [
		'readStream',
		'stringTable',
		'symbolTable',
		'readStream',
		'currentMethod'
	],
	#category : #Dynamic
}

{ #category : #all }
TtObjectDecoder class >> on: aByteStream [

	^ self new
		on: aByteStream
]

{ #category : #all }
TtObjectDecoder class >> putInstVars: instVars in: anObject [

	instVars withIndexDo: [ :instVar :index | anObject instVarAt: index put: instVar ]
]

{ #category : #all }
TtObjectDecoder >> denormalizeHeader: header [

	"De-normalize the header value of CompiledCode. (See comment of TtObjectEncoder >> #normalizeHeader:)

	Implementation:
	Reset the position of the sign flag, which is used to indicate secondary bytecode set being used."

	^ (header bitAnd: 16r40000000) ~~ 0
		ifTrue: [ (header bitAnd: 16r3fffffff) + SmallInteger minVal ]
		ifFalse: [ header ]
]

{ #category : #all }
TtObjectDecoder >> decodeAdditionalMethodState [

	"Decode AdditionalMethodState assuming only Pragmas are relevant.
	An AdditionalMethodState is only decoded in the context of a CompiledMethod."

	| additionalMethodState selector pragmas |

	selector := self readSymbol.
	pragmas := self readArray.
	additionalMethodState := AdditionalMethodState new: pragmas size.
	pragmas withIndexDo: [ :eachPragma :index | additionalMethodState basicAt: index put: eachPragma ].

	"Set the method for the AdditionalMethodState (will in turn set the method for the Pragmas)"
	currentMethod ifNil: [ self error: 'Decoding AdditionalMethodState without a method' ].
	additionalMethodState setMethod: currentMethod.

	"Set the selector for the method"
	additionalMethodState selector: selector.

	^ additionalMethodState
]

{ #category : #all }
TtObjectDecoder >> decodeArray [

	"Decode Array"

	^ self readArray
]

{ #category : #all }
TtObjectDecoder >> decodeAssociation [

	"Decode Association"

	^ Association key: self decodeNext value: self decodeNext
]

{ #category : #all }
TtObjectDecoder >> decodeCharacter [

	"Decode a Character based on a Unicode value written using UTF-8"

	^ Character value: self readUTF8CodePoint
]

{ #category : #all }
TtObjectDecoder >> decodeClass [

	"Decode a Class and install it. Answer the newly installed Class or nil if this failed.
	A failure will occur when the superclass specified does not exist."

	| newClass theSuperclass className superclassName instVarNames classVarNames |

	"Read class and superclass name"
	className := self readSymbol.
	superclassName := self readSymbol.

	"Read instance variable, class variable and share pool names"
	instVarNames := self readArray.
	classVarNames := self readArray.

	"Retrieve super class"
	(theSuperclass := Smalltalk classNamed: superclassName)
		ifNil: [

			"Create temporary class to allow cyclic dependencies"
			theSuperclass := Object
				subclass: superclassName
				instanceVariableNames: #()
				classVariableNames: #().
			Smalltalk at: superclassName put: theSuperclass ].

	"Create new or update existing subclass from our superclass"
	(Smalltalk classNamed: className)
		ifNotNil: [ :existingClass |

			"Not actually a new class, but update it to become the 'full' class"
			superclassName == #Object
				ifTrue: [ newClass := existingClass ]
				ifFalse: [
					existingClass superclass == Object
						ifTrue: [ Object removeSubclass: existingClass ].
					newClass := existingClass.
					newClass superclass: theSuperclass.
					newClass class superclass: theSuperclass class.
					newClass setFormat: newClass format + theSuperclass instSize.	"Object has no instance vars, so simply add the new inst var count"
					theSuperclass addSubclass: newClass ].

			"Update instance variables and class variables"
			instVarNames
				ifNotEmpty: [
					newClass instVarNames: instVarNames.
					newClass withAllSubclassesDo: [ :each | each setFormat: each format + instVarNames size ] ].
			classVarNames do: [ :each | newClass addClassVarNamed: each ] ]
		ifNil: [

			"Create new subclass"
			newClass := theSuperclass
				subclass: className
				instanceVariableNames: instVarNames
				classVariableNames: classVarNames ].

	"Read and install instance and class methods"
	newClass installMethodDictionary: self readMethodDictionary.
	newClass class installMethodDictionary: self readMethodDictionary.

	^ newClass
]

{ #category : #all }
TtObjectDecoder >> decodeClassReference [

	| name class |

	name := self readSymbol.
	class := Smalltalk classNamed: name.
	class ifNil: [
		"Create dummy class (helpful for cyclic dependencies) which will be updated later"
		class := Object
			subclass: name
			instanceVariableNames: #()
			classVariableNames: #().
		Smalltalk at: name put: class ].
	^ Association key: name value: class
]

{ #category : #all }
TtObjectDecoder >> decodeClassVariable [

	| name |

	name := self readSymbol.

	^ (Smalltalk at: #ClassVariable)
		key: name
		value: nil
]

{ #category : #all }
TtObjectDecoder >> decodeCompiledMethod [

	"Decode a CompiledMethod. Although it is not installed here, it will have its bound Class set
	since this is one of the CompiledMethod's literals."

	| method header bytecodeSize initialPC endPC |

	"Read header and bytecode size"
	header := self denormalizeHeader: self readUInt32.
	bytecodeSize := self readLength.

	"Create empty method instance"
	method := CompiledMethod newMethod: bytecodeSize + 4 header: header.

	"Keep reference to this method in instvar 'currentMethod' for use when decoding AdditionalMethodState or Pragmas"
	currentMethod := method.

	"Add bytecode to the method"
	initialPC := method initialPC.
	endPC := method endPC.
	initialPC to: endPC do: [ :byteIndex | method byteAt: byteIndex put: readStream next ].

	"Add literals"
	1 to: method numLiterals do: [ :index | method literalAt: index put: self decodeNext ].

	"Reference to currentMethod no longer needed (can't be nested so just set to nil)"
	currentMethod := nil.

	^ method
]

{ #category : #all }
TtObjectDecoder >> decodeCompiledBlock [

	"Decode a CompiledBlock. It will have its outerCode set,
	based on the current method being decoded (a CompiledBlock
	should only be present in context of a CompiledMethod)."

	| block header bytecodeSize initialPC endPC |

	"Read header and bytecode size"
	header := self denormalizeHeader: self readUInt32.
	bytecodeSize := self readLength.

	"Create empty block instance"
	block := CompiledBlock newMethod: bytecodeSize header: header.

	"Add bytecode to the block"
	initialPC := block initialPC.
	endPC := block endPC.
	initialPC to: endPC do: [ :byteIndex | block byteAt: byteIndex put: readStream next ].

	"Add literals  (excl. outerCode which is positioned at index 'numLiterals')"
	1 to: block numLiterals - 1 do: [ :index | block literalAt: index put: self decodeNext ].

	"Add outerCode (which resides at index 'numLiterals')"
	block outerCode: currentMethod.

	^ block
]

{ #category : #all }
TtObjectDecoder >> decodeConstantBlockClosure [

	| numArgs literal |

	"Read number of arguments and literal"
	numArgs := self readLength.
	literal := self decodeNext.

	^ ConstantBlockClosure numArgs: numArgs literal: literal
]

{ #category : #all }
TtObjectDecoder >> decodeDictionary [

	^ self readArray asDictionary
]

{ #category : #all }
TtObjectDecoder >> decodeFalse [

	^ false
]

{ #category : #all }
TtObjectDecoder >> decodeFloat [

	| word1 word2 |

	word1 := self readUInt32.
	word2 := self readUInt32.

	^ (Float new: 2)
		basicAt: 1 put: word1 ;
		basicAt: 2 put: word2 ;
		yourself
]

{ #category : #all }
TtObjectDecoder >> decodeGlobalVariable [

	| name |

	name := self readSymbol.

	^ (Smalltalk at: #GlobalVariable)
		key: name
		value: (Smalltalk at: name ifAbsent: [ self error: 'Unknown global ', name ])
]

{ #category : #all }
TtObjectDecoder >> decodeInteger0 [

	^ 0
]

{ #category : #all }
TtObjectDecoder >> decodeInteger1Byte [

	^ self readIntegerWithBytes: 1
]

{ #category : #all }
TtObjectDecoder >> decodeInteger2Bytes [

	^ self readIntegerWithBytes: 2
]

{ #category : #all }
TtObjectDecoder >> decodeInteger3Bytes [

	^ self readIntegerWithBytes: 3
]

{ #category : #all }
TtObjectDecoder >> decodeInteger4Bytes [

	^ self readIntegerWithBytes: 4
]

{ #category : #all }
TtObjectDecoder >> decodeLargeNegativeInteger [

	"Large integers are stored as special type and therefore do not need a sign bit anymore.
	Large integers are therefore stored using their positive value."

	^ self readLargePositiveInteger negated
]

{ #category : #all }
TtObjectDecoder >> decodeLargePositiveInteger [

	^ self readLargePositiveInteger
]

{ #category : #all }
TtObjectDecoder >> decodeMessageSend [

	"Decode a MessageSend"

	^ MessageSend
		receiver: self decodeNext
		selector: self readSymbol
		arguments: self decodeNext
]

{ #category : #all }
TtObjectDecoder >> decodeMessage [

	"Decode a Message (lookupClass is ignored"

	^ Message
		selector: self readSymbol
		arguments: self decodeNext
]

{ #category : #all }
TtObjectDecoder >> decodePoint [

	"Decode a Point"

	^ Point x: self decodeNext y: self decodeNext
]

{ #category : #all }
TtObjectDecoder >> decodeMetaclassReference [

	| name class |

	name := self readSymbol.
	class := Smalltalk classNamed: name.
	class ifNil: [ self error: 'Unknown class named ', name ].

	^ Association key: nil value: class class
]

{ #category : #all }
TtObjectDecoder >> decodeNext [

	| type selector |

	type := readStream next.
	selector := #(
		decodeNil
		decodeTrue
		decodeFalse
		decodeCharacter
		decodeSymbol
		decodeString
		decodeInteger0
		decodeInteger1Byte
		decodeInteger2Bytes
		decodeInteger3Bytes
		decodeInteger4Bytes
		decodeLargePositiveInteger
		decodeLargeNegativeInteger
		decodeFloat
		decodeArray
		decodeAssociation
		decodeDictionary
		decodeCompiledMethod
		decodeAdditionalMethodState
		decodePragma
		decodeClassReference
		decodeMetaclassReference
		decodeClassVariable
		decodeGlobalVariable
		decodeClass
		decodeMessageSend
		decodeMessage
		decodePoint
		decodeCompiledBlock
		decodeConstantBlockClosure
	) at: type ifAbsent: [ self error: 'Unknown type in decode stream: ', type printString ].

	^ self perform: selector
]

{ #category : #all }
TtObjectDecoder >> decodeNil [

	^ nil
]

{ #category : #all }
TtObjectDecoder >> decodePragma [

	"Decode Pragma using its keyword (aka selector) and arguments.
	A Pragma is only decoded in the context of a CompiledMethod."

	| keyword arguments |

	"The Pragma's method will be set in #decodeAdditionalMethodState just use keyword and arguments"
	keyword := self readSymbol.
	arguments := self readArray.

	^ Pragma keyword: keyword arguments: arguments
]

{ #category : #all }
TtObjectDecoder >> decodeString [

	^ self readString
]

{ #category : #all }
TtObjectDecoder >> decodeSymbol [

	^ self readSymbol
]

{ #category : #all }
TtObjectDecoder >> decodeTrue [

	^ true
]

{ #category : #all }
TtObjectDecoder >> doPeek: aBlock [

	"Evaluate aBlock while preserving the current read stream position"

	| position |

	position := readStream position.
	[ aBlock value ] ensure: [ readStream position: position ]
]

{ #category : #all }
TtObjectDecoder >> errorMalformedUTF8 [

	self error: 'Malformed UTF-8 character'
]

{ #category : #all }
TtObjectDecoder >> hasMoreData [

	^ readStream atEnd not
]

{ #category : #all }
TtObjectDecoder >> on: aByteStream [

	readStream := ReadStream on: aByteStream.

	"Implementation: The stringTable is lazy initialized"
	symbolTable := OrderedCollection new
]

{ #category : #all }
TtObjectDecoder >> readArray [

	| array size |

	size := self readLength.
	array := Array new: size.
	1 to: size do: [ :index | array at: index put: self decodeNext ].

	^ array
]

{ #category : #all }
TtObjectDecoder >> readIntegerWithBytes: byteSize [

	"Read an integer from the read stream consisting of byteSize bytes.
	It is assumed that the integer is stored in 2's complement representation and little endian order."

	| integer highByteShift |

	"Read integer as positive integer (ignore possible sign)"
	integer := self readPositiveIntegerWithSize: byteSize.

	"Update sign (and value) of integer if high bit is set"
	highByteShift := 8 * (byteSize - 1).
	(integer bitAnd: (16r80 bitShift: highByteShift)) = 0
		ifFalse: [ integer := integer - (16r100 bitShift: highByteShift) ].

	^ integer
]

{ #category : #all }
TtObjectDecoder >> readLargePositiveInteger [

	"Read a (possibly large) integer from the read stream in little endian order.
	The number of bytes is assumed to be present on the read stream (size in 2 bytes, little endian order).
	The integer is assumed to be positive (ie no sign bit)."

	| byteSize |

	"Retrieve size of integer"
	byteSize := self readLength.

	^ self readPositiveIntegerWithSize: byteSize
]

{ #category : #all }
TtObjectDecoder >> readLength [

	"Read a length value using a byte encoding where the high (8th) bit is designated to mark the final byte.
	The resulting length will be either 0 or a positive integer.
	The length is stored in little endian (least significant byte first) order."

	| length byte bitShift |

	length := 0.

	"Read 7 bits of the length at a time (little endian order)"
	bitShift := 0.
	[
		byte := readStream next.
		length := length bitOr: ((byte bitAnd: 16r7f) bitShift: bitShift).
		bitShift := bitShift + 7.
		(byte bitAnd: 16r80) = 16r80 ] whileFalse.

	^ length
]

{ #category : #all }
TtObjectDecoder >> readMethodDictionary [

	"Create and answer a MethodDictionary from the methods read.

	Implementation:
	Create the MethodDictionary with enough size to hold all methods and be performant for
	accessing elements (hash behavior). This also prevents having to grow the MethodDictionary
	during installation of individual methods. See Set >> #fullCheck."

	| methods methodDictionary |

	methods := self readArray.
	methodDictionary := MethodDictionary new: methods size + (methods size // 4 max: 1).
	methods do: [ :eachMethod | methodDictionary at: eachMethod selector put: eachMethod ].

	^ methodDictionary
]

{ #category : #all }
TtObjectDecoder >> readPositiveIntegerWithSize: byteSize [

	"Read integer from readStream as positive integer (ignore possible sign bit).
	Assume integer is byteSize bytes long and is stored in little endian order."

	| integer |

	integer := 0.
	0 to: byteSize - 1 do: [ :byteShift | integer := integer bitOr: (readStream next bitShift: 8 * byteShift) ].

	^ integer
]

{ #category : #all }
TtObjectDecoder >> readString [

	"Read a String (should not be a Symbol)"

	^ self basicReadStringUsingTable: (stringTable ifNil: [ stringTable := OrderedCollection new ])
]

{ #category : #all }
TtObjectDecoder >> readSymbol [

	"Read a Symbol (should not be a String)"

	^ self basicReadStringUsingTable: symbolTable
]

{ #category : #all }
TtObjectDecoder >> basicReadStringUsingTable: aCollection [

	"Read a String (can be a Symbol) using the specified table space (cache)"

	| characterCount |

	characterCount := self readLength.
	(characterCount = 2 and: [ self peekHasStringIndex ])
		ifTrue: [ ^ self basicReadStringWithIndexUsingTable: aCollection ].

	^ self basicReadStringWithLength: characterCount usingTable: aCollection
]

{ #category : #all }
TtObjectDecoder >> basicReadStringWithIndexUsingTable: aCollection [

	"Read an index (into either the String or Symbol table) from the read stream.
	Assume the index is max 11 bits big.

	See TtObjectEncoder >> #basicWriteStringIndex: for an explanation."

	| index string |

	"Read index which is 0-based"
	index := ((readStream next bitAnd: 16r07) bitShift: 8) bitOr: readStream next.
	index := index + 1.

	string := aCollection
		at: index
		ifAbsent: [
			self crError: 'Error during String decoding: Accessing indexed String from invalid location ', index printString.

			"Answer an appropriate empty String"
			^ aCollection == stringTable
				ifTrue: [ '' ]
				ifFalse: [ #'' ] ].

	"For Strings (not Symbols) make a copy since these are unique instances"
	^ aCollection == stringTable
		ifTrue: [ string copy ]
		ifFalse: [ string ]
]

{ #category : #all }
TtObjectDecoder >> basicReadStringWithLength: anInteger usingTable: aCollection [

	"Read a String consisting of UTF-8 characters and store it in the specified table space (cache)"

	| wordArray isWideString string |

	"Create and fill the string"
	wordArray := WordArray new: anInteger.
	isWideString := false.
	1 to: anInteger do: [  :index |
		(wordArray at: index put: self readUTF8CodePoint) >= 256
			ifTrue: [ isWideString := true ] ].

	string := isWideString
		ifTrue: [ WideString fromWordArray: wordArray ]
		ifFalse: [ ByteString fromWordArray: wordArray ].

	aCollection == symbolTable
		ifTrue: [ string := string asSymbol ].

	^ aCollection add: string
]

{ #category : #all }
TtObjectDecoder >> peekHasStringIndex [

	"Answer whether a String index is on the read stream.

	See TtObjectEncoder >> #basicWriteStringIndex: for an explanation."

	^ (readStream peek bitAnd: 16rf8) = 16rf8
]

{ #category : #all }
TtObjectDecoder >> readUInt32 [

	"Read uint32 using little endian (least significant byte first) order"

	^ self readPositiveIntegerWithSize: 4
]

{ #category : #all }
TtObjectDecoder >> readUTF8CodePoint [

	"Read a Unicode value written using UTF-8.
	See also https://en.wikipedia.org/wiki/UTF-8"

	| unicode |

	unicode := readStream next.
	(unicode bitAnd: 16r80) = 0 	"Encoding 0xxxxxxx for single byte UTF-8 character"
		ifFalse: [

			| bytesToRead byte |

			"Decide additional number of bytes to read"
			(unicode bitAnd: 16re0) = 16rc0 	"Encoding 110xxxxx for 2-byte UTF-8 character"
				ifTrue: [ bytesToRead := 1 ]
				ifFalse: [
					(unicode bitAnd: 16rf0) = 16re0 	"Encoding 1110xxxx for 3-byte UTF-8 character"
						ifTrue: [ bytesToRead := 2 ]
						ifFalse: [
							(unicode bitAnd: 16rf8) = 16rf0 	"Encoding 11110xxx for 4-byte UTF-character"
								ifTrue: [ bytesToRead := 3 ]
								ifFalse: [ self errorMalformedUTF8 ] ] ].

			"Remove encoding bits from first unicode byte"
			unicode := unicode bitAnd: (16r3f bitShift: bytesToRead negated).

			"Read additional bytes (removing encoding bits 10xxxxxx)"
			bytesToRead timesRepeat: [
				byte := readStream next.
				(byte bitAnd: 16rc0) = 16r80 	"check continuation bit"
					ifFalse: [ self errorMalformedUTF8 ].
				unicode := (unicode bitShift: 6) bitOr: (byte bitAnd: 16r3f) ] ].

	^ unicode
]

{ #category : #all }
TtObjectDecoder >> remainingBytes [

	"Answer the remaining bytes of the receiver"

	^ readStream upToEnd
]
