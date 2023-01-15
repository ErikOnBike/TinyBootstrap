Class {
	#name : #CompiledMethod,
	#superclass : #CompiledCode,
	#type : #bytes,
	#category : #'Kernel-Methods'
}

{ #category : #all }
CompiledMethod >> endPC [
	"Answer the index of the last bytecode."
	| size flagByte |
	"Can't create a zero-sized CompiledMethod so no need to use last for the errorEmptyCollection check.
	 We can reuse size."
	size := self size.
	flagByte := self at: size.
	flagByte = 0 ifTrue: [
		"If last byte = 0, may be either 0, 0, 0, 0 or just 0"
		size-1 to: size-3 by: -1 do: [ :i |
			i < self initialPC ifTrue: [ ^ i ].
			(self at: i) = 0 ifFalse: [ ^ i ]].
		^size - 4].
	flagByte < 252 ifTrue: [
		"Magic sources (temp names encoded in last few bytes)"
		^flagByte <= 127
			ifTrue: [size - flagByte - 1]
			ifFalse: [size - (flagByte - 128 * 128) - (self at: size - 1) - 2]].
	"Normal 4-byte source pointer"
	^size - 4
]

{ #category : #all }
CompiledMethod >> penultimateLiteral [
	| pIndex |
	^ (pIndex := self numLiterals - 1) > 0 
		ifTrue: [ self literalAt: pIndex ]
		ifFalse: [ nil ]
]

{ #category : #all }
CompiledMethod >> selector [
	| penultimateLiteral | 
	^ (penultimateLiteral := self penultimateLiteral) isMethodProperties
		ifTrue: [ penultimateLiteral selector ]
		ifFalse: [ penultimateLiteral ]
]

{ #category : #all }
CompiledMethod >> properties [

	"Answer the method properties of the receiver.
	Implementation: currently only supported through method properties in receiver directly."

	| penultimateLiteral |
	^(penultimateLiteral := self penultimateLiteral) isMethodProperties
		ifTrue: [penultimateLiteral]
		ifFalse: [nil "self class methodPropertiesClass forMethod: self selector: penultimateLiteral"]
]

{ #category : #all }
CompiledMethod >> pragmas [
	^ self properties ifNotNil: [ :properties | properties pragmas ] ifNil: [ #() ]
]

{ #category : #all }
CompiledMethod >> methodClass [
	^ self classBinding value
]

{ #category : #all }
CompiledMethod >> classBinding [
	"Answer the association to the class that I am installed in, or nil if none."
	^ self literalAt: self numLiterals
]

{ #category : #all }
CompiledMethod >> install [

	self methodClass
		ifNotNil: [ :methodClass | 
			methodClass addSelector: self selector withMethod: self.
			self bindClassVariablesTo: methodClass instanceSide ]
]

{ #category : #all }
CompiledMethod >> bindClassVariables [

	"Bind class variables to the receiver (replace literal association with class variable association).
	Assume the receiver is already bound to a class."

	self bindClassVariablesTo: self methodClass instanceSide
]

{ #category : #all }
CompiledMethod >> bindClassVariablesTo: aClass [

	"Bind class variables to the receiver (replace literal association with class variable association)"

	| classVariableClass |

	classVariableClass := Smalltalk at: #ClassVariable.
	1 to: self numLiterals do: [ :index |
		| literal |
		literal := self literalAt: index.
		(literal class == classVariableClass and: [ literal value isNil ])
			ifTrue: [ self literalAt: index put: (aClass classVariableNamed: literal key) ] ]
]

{ #category : #all }
CompiledMethod >> primitive [
	"Answer the primitive index associated with the receiver.
	 Zero indicates that this is not a primitive method."
	| initialPC |
	^(self header anyMask: 65536) "Is the hasPrimitive? flag set?"
		ifTrue: [(self at: (initialPC := self initialPC) + 1) + ((self at: initialPC + 2) bitShift: 8)]
		ifFalse: [0]
]

{ #category : #all }
CompiledMethod >> isCompiledMethod [
	^ true
]

{ #category : #all }
CompiledMethod >> printOn: aStream [
	aStream
		nextPutAll: self methodClass name ;
		nextPutAll: ' >> '.
	self selector printOn: aStream
]
