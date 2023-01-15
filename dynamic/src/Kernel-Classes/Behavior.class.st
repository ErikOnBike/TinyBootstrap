Class {
	#name : #Behavior,
	#superclass : #Object,
	#instVars : [
		'superclass',
		'methodDict',
		'format'
	],
	#category : #'Kernel-Classes'
}

{ #category : #all }
Behavior >> >> aSelector [
	^ methodDict at: aSelector
]

{ #category : #all }
Behavior >> selectors [
	^ methodDict keys
]

{ #category : #all }
Behavior >> allInstVarNames [
	"Answer an Array of the names of all my instance variables."
	
	^ (1 to: self instSize) collect: [ :i | 'instVar' , i printString ]
]

{ #category : #all }
Behavior >> allInstances [
	"Answer a collection of all current instances of the receiver."

	| all |
	all := OrderedCollection new.
	self
		allInstancesDo: [ :x | 
			x == all
				ifFalse: [ all add: x ] ].
	^ all asArray
]

{ #category : #all }
Behavior >> allInstancesDo: aBlock [
	"Evaluate the given block for each instance of the receiver."

	| inst |
	self == UndefinedObject
		ifTrue: [ ^ aBlock value: nil ].
	inst := self someInstance.
	[ inst == nil ]
		whileFalse: [ aBlock value: inst.
			inst := inst nextInstance ]
]

{ #category : #all }
Behavior >> basicNew [
	"Primitive. Answer an instance of the receiver (which is a class) with no indexable fields. Fail if the class is variable-sized. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 70>
	self isVariable
		ifTrue: [ ^ self basicNew: 0 ].	"space must be low"
	self error: 'low space'
]

{ #category : #all }
Behavior >> basicNew: desiredSize [
	"Primitive. Answer an instance of this class with the given number of indexable variables. Fail if this class is not indexable, if the argument is not a positive Integer, or if there is not enough memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 71>
	self isVariable
		ifFalse: [ self error: self name , ' is not variable-sized' ].
	(desiredSize isInteger not or: [ desiredSize < 0 ])
		ifTrue: [ self error: 'bad size' ].
	self error: 'low space'
]

{ #category : #all }
Behavior >> canUnderstand: selector [
	"Answer whether the receiver can respond to the message whose selector is the argument. The selector can be in the method dictionary of the receiver's class or any of its superclasses."

	^ (self lookupSelector: selector) ~~ nil
]

{ #category : #all }
Behavior >> classPool [
	^ nil
]

{ #category : #all }
Behavior >> format [
	"Answer a integer that encodes the format of instances of this class receiver."

	^ format
]

{ #category : #all }
Behavior >> indexIfCompact [
	"If my compact class index is non-zero, then instances of this class will be compact, and their class will have an entry in Smalltalk compactClassesArray."

	^ (format bitShift: -11) bitAnd: 16r1F
]

{ #category : #all }
Behavior >> inheritsFrom: aClass [
	"Answer whether the argument is on the receiver's superclass chain."

	| this |
	this := superclass.
	[ this == nil ]
		whileFalse: [ this == aClass
				ifTrue: [ ^ true ].
			this := this superclass ].
	^ false
]

{ #category : #all }
Behavior >> includesBehavior: aClass [

	^ self == aClass or: [ self inheritsFrom: aClass ]
]

{ #category : #all }
Behavior >> initialize [
	"Default initialization."

	superclass := Object.
	format := 0.
	methodDict := MethodDictionary new
]

{ #category : #all }
Behavior >> instSize [
	"Answer the number of named instance variables
	(as opposed to indexed variables) of the receiver.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>"
	^format bitAnd: 16rFFFF
]

{ #category : #all }
Behavior >> instSpec [
	"Answer the instance specification part of the format that defines what kind of object
	 an instance of the receiver is.  The formats are
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (Context AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	^(self format bitShift: -16) bitAnd: 16r1F
]

{ #category : #all }
Behavior >> isBehavior [
	"Answer true if I am a subclass of Behavior."

	^ true
]

{ #category : #all }
Behavior >> isBits [
	"Answer whether the receiver contains just bits (not pointers)."

	^ self instSpec >= 6
]

{ #category : #all }
Behavior >> isBytes [
	"Answer true if the receiver is byte-indexable. This is always false for non-indexable and pointer objects."

	^ self instSpec >= 8
]

{ #category : #all }
Behavior >> isCompact [
	^ self indexIfCompact ~= 0
]

{ #category : #all }
Behavior >> isPointers [
	"Answer true if the receiver contains object pointers (versus bytes or words)."

	^ self isBits not
]

{ #category : #all }
Behavior >> isVariable [
	"Answer true if the receiver has indexable fields."

	^ self instSpec >= 2
]

{ #category : #all }
Behavior >> lookupSelector: selector [
	"Look up the given selector in the methodDictionaries of every class in my superclass chain and answer the corresponding method if found. Answer nil if no method is found."

	| lookupClass mDict |
	lookupClass := self.
	[ lookupClass == nil ]
		whileFalse: [ mDict := lookupClass methodDictionary.
			(mDict includesKey: selector)
				ifTrue: [ ^ mDict at: selector ].
			lookupClass := lookupClass superclass ].
	^ nil
]

{ #category : #all }
Behavior >> includesSelector: aSymbol [
	"Answer whether the message whose selector is the argument is in the 
	method dictionary of the receiver's class."

	^ methodDict includesKey: aSymbol
]

{ #category : #all }
Behavior >> methodDictionary [
	"Answer my method dictionary."

	^ methodDict
]

{ #category : #all }
Behavior >> methodDictionary: aMethodDictionary [
	"Set my method dictionary."

	methodDict := aMethodDictionary
]

{ #category : #all }
Behavior >> addSelectorSilently: aSymbol withMethod: aCompiledMethod [
	methodDict at: aSymbol put: aCompiledMethod.
]

{ #category : #all }
Behavior >> addSelector: aSymbol withMethod: aCompiledMethod [
	methodDict at: aSymbol put: aCompiledMethod.
	self flushMethodCacheForSelector: aSymbol.
]

{ #category : #all }
Behavior >> selectorAndMethodsDo: aTwoArgBlock [
	^ methodDict keysAndValuesDo: aTwoArgBlock
]

{ #category : #all }
Behavior >> flushMethodCacheForSelector: aSelector [
	aSelector flushCache
]

{ #category : #all }
Behavior >> name [
	"Answer a String that names the receiver as well possible. Overridden by my subclasses."

	superclass
		ifNil: [ ^ 'a subclass of nil' ]
		ifNotNil: [ ^ 'a subclass of ' , superclass name ]
]

{ #category : #all }
Behavior >> new [
	^ self basicNew
]

{ #category : #all }
Behavior >> new: desiredSize [
	^ self basicNew: desiredSize
]

{ #category : #all }
Behavior >> printOn: aStream [
	aStream nextPutAll: self name
]

{ #category : #all }
Behavior >> selectorAtMethod: method setClass: classResultBlock [
	"Answer the message selector associated with the compiled method and evaluate the classResultBlock on the class in which that selector is defined."

	"Note: This method is here only to support the debugger."

	| sel |
	sel := methodDict
		keyAtIdentityValue: method
		ifAbsent: [ superclass
				ifNil: [ classResultBlock value: self.
					^ #DoIt ].
			sel := superclass
				selectorAtMethod: method
				setClass: classResultBlock.
			sel == #DoIt
				ifTrue: [ classResultBlock value: self ].	"if selector is DoIt, set class to me"
			^ sel ].
	classResultBlock value: self.
	^ sel
]

{ #category : #all }
Behavior >> setCompactClassIndex: ccIndex [
	"If my compact class index is non-zero, then instances of this class will be compact, and their class will have an entry in Smalltalk compactClassesArray."

	(ccIndex > 0 and: [ ccIndex <= 31 ])
		ifFalse: [ ^ self error: 'compact class index must 1-31' ].
	self indexIfCompact = 0
		ifFalse: [ ^ self error: self name , ' is already compact!' ].
	format := format + (ccIndex bitShift: 11)
]

{ #category : #all }
Behavior >> setFormat: anInteger [
	"Warning! Risky operation. Should only be done when there are not instances of this class."

	format := anInteger
]

{ #category : #all }
Behavior >> sharedPools [
	^ nil
]

{ #category : #all }
Behavior >> someInstance [
	"Primitive. Answer the first instance in the enumeration of all instances of the receiver. Answer nil if there are none. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 77>
	^ nil
]

{ #category : #all }
Behavior >> superclass [
	"Answer my superclass."

	^ superclass
]

{ #category : #all }
Behavior >> superclass: aBehaviorOrNil [
	"Set my superclass."

	superclass := aBehaviorOrNil
]

{ #category : #all }
Behavior >> installMethodDictionary: aMethodDictionary [
	methodDict := aMethodDictionary.
	aMethodDictionary valuesDo: [ :each | each bindClassVariables ]
]
