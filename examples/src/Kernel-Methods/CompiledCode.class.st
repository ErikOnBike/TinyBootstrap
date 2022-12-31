Class {
	#name : #CompiledCode,
	#superclass : #ByteArray,
	#type : #bytes,
	#category : #'Kernel-Methods'
}

{ #category : #all }
CompiledCode class >> newMethod: numberOfBytes header: headerWord [
	"Primitive. Answer an instance of me. The number of literals (and other 
	 information) is specified by the headerWord.
	 The first argument specifies the number of fields for bytecodes in the
	 method. Fail if either argument is not a SmallInteger, or if numberOfBytes
	 is negative, or if memory is low. Once the header of a method is set by
	 this primitive, it cannot be changed to change the number of literals.
	 Essential. See Object documentation whatIsAPrimitive."

	<primitive: 79>
	^nil
]

{ #category : #all }
CompiledCode >> frameSize [
	"Answer the size of temporary frame needed to run the receiver."

	"NOTE:  Versions 2.7 and later use two sizes of contexts."

	(self header bitAnd: 16r20000) = 0
		ifTrue: [ ^ 16 ]
		ifFalse: [ ^ 56 ]
]

{ #category : #all }
CompiledCode >> header [
	"Answer the method header word containing information about the form of this method (e.g., number of literals) and the context needed to run it."

	^ self objectAt: 1
]

{ #category : #all }
CompiledCode >> initialPC [
	"Answer the program counter for my first bytecode."

	^ (self numLiterals + 1) * Smalltalk wordSize + 1
]

{ #category : #all }
CompiledCode >> numArgs [
	"Answer the number of arguments the receiver takes."

	^ (self header bitShift: -24) bitAnd: 16r0F
]

{ #category : #all }
CompiledCode >> numLiterals [
	"Answer the number of literals used by the receiver."

	^ self header bitAnd: 16r7FFF
]

{ #category : #all }
CompiledCode >> numTemps [
	"Answer the number of temporary variables used by this method."

	^ (self header bitShift: -18) bitAnd: 16r3F
]

{ #category : #all }
CompiledCode >> literalAt: index [
	"Answer the literal indexed by the argument."

	^self objectAt: index + 1
]

{ #category : #all }
CompiledCode >> literalAt: index put: value [
	"Replace the literal indexed by the first argument with the second 
	argument. Answer the second argument."

	^self objectAt: index + 1 put: value
]

{ #category : #all }
CompiledCode >> objectAt: index [
	"Primitive. Answer the method header (if index = 1) or a literal (if index > 1) from the receiver. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 68>
	self primitiveFailed
]

{ #category : #all }
CompiledCode >> objectAt: index put: value [
	"Primitive. Store the value argument into a literal in the receiver. An index of 2 corresponds to the first literal. Fails if the index is less than 2 or greater than the number of literals. Answer the value as the result. Normally only the compiler sends this message because only the compiler stores values in CompiledMethods. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 69>
	self primitiveFailed
]
