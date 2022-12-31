Class {
	#name : #CompiledBlock,
	#superclass : #CompiledCode,
	#type : #bytes,
	#category : #'Kernel-Methods'
}

{ #category : #all }
CompiledBlock >> endPC [
	^ self size
]

{ #category : #all }
CompiledBlock >> methodClass [
	"answer the compiled method that I am installed in, or nil if none."
	^ self outerCode methodClass
]

{ #category : #all }
CompiledBlock >> selector [
	^ self outerCode selector
]

{ #category : #all }
CompiledBlock >> outerCode [
	"Answer the compiled code that I am installed in, or nil if none."
	^ self literalAt: self numLiterals
]

{ #category : #all }
CompiledBlock >> outerCode: aCompiledCode [
	self literalAt: self numLiterals put: aCompiledCode
]

{ #category : #all }
CompiledBlock >> primitive [
	"Zero indicates that this is not a primitive method."
	^ 0
]

{ #category : #all }
CompiledBlock >> isCompiledBlock [
	^ true
]

{ #category : #all }
CompiledBlock >> printOn: aStream [
	aStream nextPutAll: 'CompiledBlock in '.
	self outerCode printOn: aStream
]
