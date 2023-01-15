Class {
	#name : #ClassBuilder,
	#superclass : #Object,
	#instVars : [
		'superclass',
		'name',
		'instanceVariableNames',
		'classVariableNames',
		'formats'
	],
	#category : #'Kernel-Classes'
}

{ #category : #all }
ClassBuilder >> beBytes [
	self isCompiledMethodClassIndex
		ifTrue: [ ^ self beCompiledMethod ].
	^ formats := #(#variable #bytes)
]

{ #category : #all }
ClassBuilder >> beCompiledMethod [
	^ formats := #(#compiledMethod #variable #bytes)
]

{ #category : #all }
ClassBuilder >> beImmediate [
	^ formats := #(immediate)
]

{ #category : #all }
ClassBuilder >> bePointers [
	^ formats := #(#pointers)
]

{ #category : #all }
ClassBuilder >> beVariable [
	^ formats := #(#variable #pointers)
]

{ #category : #all }
ClassBuilder >> beWeak [
	^ formats := #(#weak #variable #pointers)
]

{ #category : #all }
ClassBuilder >> beWords [
	^ formats := #(#variable #words)
]

{ #category : #all }
ClassBuilder >> build [
	| metaclass theClass supermetaclass |

	supermetaclass := superclass
		ifNil: [ Class ]
		ifNotNil: [ superclass class ].
	metaclass := Metaclass new.
	metaclass superclass: supermetaclass.
	metaclass setFormat: supermetaclass format.
	theClass := metaclass new.
	theClass superclass: superclass.
	theClass setFormat: self newClassFormat.
	theClass instVarNames: instanceVariableNames.
	theClass name: name.
	theClass classPool: (classVariableNames collect: [ :classVarName | Association key: classVarName value: nil ]) asDictionary.
	superclass ifNotNil: [ superclass addSubclass: theClass ].

	"Store class in Smalltalk globals (for referencing from methods)"
	Smalltalk at: name put: theClass.

	^ theClass
]

{ #category : #all }
ClassBuilder >> classVariableNames [
	^ classVariableNames
]

{ #category : #all }
ClassBuilder >> classVariableNames: anArray [
	classVariableNames := anArray
]

{ #category : #all }
ClassBuilder >> compactClassIndex [
	^ self compactClassIndexFor: name
]

{ #category : #all }
ClassBuilder >> compactClassIndexFor: aClassName [
	^ #(#CompiledMethod nil #Array #LargeNegativeInteger #LargePositiveInteger #Float nil #Association #Point #Rectangle #ByteString #BlockClosure nil #Context nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil)
		indexOf: aClassName
		ifAbsent: [ 0 ]
]

{ #category : #all }
ClassBuilder >> initialize [
	super initialize.
	instanceVariableNames := #().
	classVariableNames := #().
	superclass := Object.
	self bePointers
]

{ #category : #all }
ClassBuilder >> instSize [
	^ (superclass ifNil: [ 0 ] ifNotNil: [ superclass instSize ])
		+ instanceVariableNames size
]

{ #category : #all }
ClassBuilder >> instSpec [
	"NEW:
	 0 = 0 sized objects (UndefinedObject True False et al)
	 1 = non-indexable objects with inst vars (Point et al)
	 2 = indexable objects with no inst vars (Array et al)
	 3 = indexable objects with inst vars (Context AdditionalMethodState et al)
	 4 = weak indexable objects with inst vars (WeakArray et al)
	 5 = weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
	 6 = reserved
	 7 = forwarder format (also immediate class format)
	 9          64-bit indexable
	 10 - 11 32-bit indexable
	 12 - 15 16-bit indexable
	 16 - 23 byte indexable
	 24 - 31 compiled method"

	(self isImmediate) ifTrue: [ ^ 7 ].	
	(self isCompiledMethod) ifTrue: [ ^ 24 ].
	(self isBytes) ifTrue: [ ^ 16 ].
	(self isWords) ifTrue: [ ^ 10 ].
	"(self isEphemeron) ifTrue: [ ^ 5 ]."
	(self instSize = 0 and: [ self isVariable not ]) ifTrue: [ ^ 0 ].
	(self instSize > 0 and: [ self isVariable not ]) ifTrue: [ ^ 1 ].
	(self instSize = 0 and: [ self isVariable     ]) ifTrue: [ ^ 2 ].
	(self instSize > 0 and: [ self isVariable     ]) ifTrue: [ ^ 3 ].
	(self instSize > 0 and: [ self isVariable and: [ self isWeak ] ]) ifTrue: [ ^ 4 ].
	(self instSize > 0 and: [ self isVariable not and: [ self isWeak ] ]) ifTrue: [ ^ 5 ].

	self error: 'illegal old format'
]

{ #category : #all }
ClassBuilder >> instVarNames: anArray [
	instanceVariableNames := anArray
]

{ #category : #all }
ClassBuilder >> isBytes [
	^ formats includes: #bytes
]

{ #category : #all }
ClassBuilder >> isCompiledMethod [
	^ formats includes: #compiledMethod
]

{ #category : #all }
ClassBuilder >> isCompiledMethodClassIndex [
	^ (self compactClassIndexFor: name)
		== (self compactClassIndexFor: #CompiledMethod)
]

{ #category : #all }
ClassBuilder >> isImmediate [

	^ formats includes: #immediate
]

{ #category : #all }
ClassBuilder >> isPointers [
	^ formats includes: #pointers
]

{ #category : #all }
ClassBuilder >> isVariable [
	^ formats includes: #variable
]

{ #category : #all }
ClassBuilder >> isWeak [
	^ formats includes: #weak
]

{ #category : #all }
ClassBuilder >> isWords [
	^ formats includes: #words
]

{ #category : #all }
ClassBuilder >> name: aName [
	name := aName
]

{ #category : #all }
ClassBuilder >> newClassFormat [

	"A class format is composed by"
	"<5 bits inst spec><16 bits inst size>"
	| instSize newInstSpec |

	instSize := self instSize.
	newInstSpec := self instSpec.
	^(newInstSpec bitShift: 16) + instSize
]

{ #category : #all }
ClassBuilder >> superclass: aClass [
	superclass := aClass
]
