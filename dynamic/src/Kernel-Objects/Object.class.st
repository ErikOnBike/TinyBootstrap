Class {
	#name : #Object,
	#superclass : #ProtoObject,
	#category : #'Kernel-Objects'
}

{ #category : #all }
Object class >> cannotInstantiate [
	"This message is sent if you try to create new instances of classes with unique instances such as booleans or characters."

	self error: 'You cannot create new instances of ' , self name
]

{ #category : #all }
Object class >> new [
	"Create a new instance of me and initialize it."

	^ self basicNew initialize
]

{ #category : #all }
Object >> -> anObject [
	"Answer an Association with myself as its key and anObject as its value."

	^ Association new key: self value: anObject
]

{ #category : #all }
Object >> = anObject [
	"Answer whether the receiver and the argument represent the same 
	object. If = is redefined in any subclass, consider also redefining the 
	message hash."

	^ self == anObject
]

{ #category : #all }
Object >> == anObject [
	"Primitive. Answer whether the receiver and the argument are the same 
	object (have the same object pointer). Do not redefine the message == in 
	any other class! Essential. No Lookup. Do not override in any subclass. 
	See Object documentation whatIsAPrimitive."

	<primitive: 110>
	self primitiveFailed
]

{ #category : #all }
Object >> asLink [
	^ ValueLink value: self
]

{ #category : #all }
Object >> asString [
	^ self printString
]

{ #category : #all }
Object >> at: index [
	"Primitive. Assumes receiver is indexable. Answer the value of an indexable element in the receiver. Fail if the argument index is not an  Integer or is out of bounds. Essential. Do not override in a subclass. See Object documentation whatIsAPrimitive."

	<primitive: 60>
	index isInteger
		ifTrue: [ self errorSubscriptBounds: index ].
	index isNumber
		ifTrue: [ ^ self basicAt: index asInteger ]
		ifFalse: [ self errorNonIntegerIndex ]
]

{ #category : #all }
Object >> at: index put: value [
	"Primitive. Assumes receiver is indexable. Store the second argument 
	value in the indexable element of the receiver indicated by index. Fail 
	if the index is not an Integer or is out of bounds. Or fail if the value is 
	not of the right type for this kind of collection. Answer the value that 
	was stored. Essential. Do not override in a subclass. See Object 
	documentation whatIsAPrimitive."

	<primitive: 61>
	index isInteger
		ifTrue: [ (index >= 1 and: [ index <= self size ])
				ifTrue: [ self errorImproperStore ]
				ifFalse: [ self errorSubscriptBounds: index ] ].
	index isNumber
		ifTrue: [ ^ self basicAt: index asInteger put: value ]
		ifFalse: [ self errorNonIntegerIndex ]
]

{ #category : #all }
Object >> basicAt: index [
	"Primitive. Assumes receiver is indexable. Answer the value of an indexable element in the receiver. Fail if the argument index is not an  Integer or is out of bounds. Essential. Do not override in a subclass. See Object documentation whatIsAPrimitive."

	<primitive: 60>
	index isInteger
		ifTrue: [ self errorSubscriptBounds: index ].
	index isNumber
		ifTrue: [ ^ self basicAt: index asInteger ]
		ifFalse: [ self errorNonIntegerIndex ]
]

{ #category : #all }
Object >> basicAt: index put: value [
	"Primitive. Assumes receiver is indexable. Store the second argument 
	value in the indexable element of the receiver indicated by index. Fail 
	if the index is not an Integer or is out of bounds. Or fail if the value is 
	not of the right type for this kind of collection. Answer the value that 
	was stored. Essential. Do not override in a subclass. See Object 
	documentation whatIsAPrimitive."

	<primitive: 61>
	index isInteger
		ifTrue: [ (index >= 1 and: [ index <= self size ])
				ifTrue: [ self errorImproperStore ]
				ifFalse: [ self errorSubscriptBounds: index ] ].
	index isNumber
		ifTrue: [ ^ self basicAt: index asInteger put: value ]
		ifFalse: [ self errorNonIntegerIndex ]
]

{ #category : #all }
Object >> basicCopy [
	"Answer a copy of the receiver that shares the receiver's instance variables. This is usually handled by the primitive, so the code below is for documentation."

	<primitive: 148>
	| class result sz |
	class := self class.
	class isVariable
		ifTrue: [ sz := self basicSize.
			result := class basicNew: sz.
			1 to: sz do: [ :i | result basicAt: i put: (self basicAt: i) ] ]
		ifFalse: [ result := class basicNew ].
	1 to: class instSize do: [ :i | result instVarAt: i put: (self instVarAt: i) ].
	^ result
]

{ #category : #all }
Object >> basicIdentityHash [
	"Answer a SmallInteger whose value is related to the receiver's identity.
	This method must not be overridden, except by SmallInteger.
	Primitive. Fails if the receiver is a SmallInteger. Essential.
	See Object documentation whatIsAPrimitive.

	Do not override. Use #identityHash unless you really know what you're doing.'"

	<primitive: 75>
	self primitiveFailed
]

{ #category : #all }
Object >> basicSize [
	"Primitive. Answer the number of indexable variables in the receiver. This value is the same as the largest legal subscript. Essential. Do not override in any subclass. See Object documentation whatIsAPrimitive."

	<primitive: 62>
	^ 0	"for fixed-size objects"
]

{ #category : #all }
Object >> become: otherObject [
	"Swap the object pointers of the receiver and the argument. After this, all variables in the entire system that used to point to the receiver now point to the argument, and vice-versa. Fails if either object is a SmallInteger."

	{ self } elementsExchangeIdentityWith: { otherObject }
]

{ #category : #all }
Object >> becomeForward: otherObject [
	"All variables in the entire system that used to point
	to the receiver now point to the argument.
	Fails if either argument is a SmallInteger."

	{ self } elementsForwardIdentityTo: { otherObject }
]

{ #category : #all }
Object >> beep [
	"Emit a short beep sound. Do nothing if the primitive fails."

	<primitive: 140>
	
]

{ #category : #all }
Object >> class [
	"Primitive. Answer the object which is the receiver's class. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 111>
	self primitiveFailed
]

{ #category : #all }
Object >> copy [
	"Answer a copy of me. Subclasses should usually override this method to change copying behavior, not basicCopy.
	The exception is classes with unique instances, such as Symbol.
	This operation does not generally copy all the objects that I refer to.
	Implement postCopy to copy any referred objects."

	^ self basicCopy postCopy
]

{ #category : #all }
Object >> postCopy [
	"Perform any post copy behavior (see comments in #copy)"
]

{ #category : #all }
Object >> doesNotUnderstand: aMessage [
	 "Handle the fact that there was an attempt to send the given message to the receiver but the receiver does not understand this message (typically sent from the machine when a message is sent to the receiver and no method is defined for that selector)."
	"Testing: (3 activeProcess)"
		
	| exception resumeValue |

	(exception := MessageNotUnderstood new)
		message: aMessage ;
		receiver: self.
	resumeValue := exception signal.
	^ exception reachedDefaultHandler
		ifTrue: [ aMessage sentTo: self ]
		ifFalse: [ resumeValue ]
]

{ #category : #all }
Object >> error: aString [
	"Throw a generic Error exception."

	^ Error signal: aString
]

{ #category : #all }
Object >> errorImproperStore [
	"Error: an improper store was attempted."

	self error: 'Improper store into indexable object.'
]

{ #category : #all }
Object >> errorNonIntegerIndex [
	"Error: attempting to use a non-integer object as an index."

	self error: 'Only integers should be used as indices.'
]

{ #category : #all }
Object >> errorSubscriptBounds: index [
	"Error: the given index is out of range."

	self error: 'Subscript is out of bounds: ' , index printString
]

{ #category : #all }
Object >> hash [
	"Answer a SmallInteger whose value is related to the receiver's identity.
	May be overridden, and should be overridden in any classes that define = "

	^ self identityHash
]

{ #category : #all }
Object >> identityHash [
	"Answer a SmallInteger whose value is related to the receiver's identity. This method must not be overridden, except by SmallInteger. Primitive. Fails if the receiver is a SmallInteger. Essential. See Object documentation whatIsAPrimitive. Do not override!"

	^ self basicIdentityHash bitShift: 8
]

{ #category : #all }
Object >> ifNil: nilBlock [
	"Return self, or evaluate the block if I'm == nil (q.v.)"

	^ self
]

{ #category : #all }
Object >> ifNil: nilBlock ifNotNil: ifNotNilBlock [
	"Evaluate the block, unless I'm == nil (q.v.)"

	^ ifNotNilBlock cull: self
]

{ #category : #all }
Object >> ifNotNil: ifNotNilBlock [
	"Evaluate the block, unless I'm == nil (q.v.)"

	^ ifNotNilBlock cull: self
]

{ #category : #all }
Object >> ifNotNil: ifNotNilBlock ifNil: nilBlock [
	"If I got here, I am not nil, so evaluate the block ifNotNilBlock"

	^ ifNotNilBlock cull: self
]

{ #category : #all }
Object >> initialize [
	"Initialize this object. Usually called by new when a new object is created. This default implementation does nothing."

	^ self
]

{ #category : #all }
Object >> release [
	"Release this objects dependencies"

	^ self
]

{ #category : #all }
Object >> instVarAt: index [
	"Primitive. Answer a fixed variable in an object. The numbering of the 
	variables corresponds to the named instance variables. Fail if the index 
	is not an Integer or is not the index of a fixed variable. Essential. See 
	Object documentation whatIsAPrimitive."

	"Access beyond fixed variables."

	<primitive: 73>
	^ self basicAt: index - self class instSize
]

{ #category : #all }
Object >> instVarAt: anInteger put: anObject [
	"Primitive. Store a value into a fixed variable in the receiver. The 
	numbering of the variables corresponds to the named instance variables. 
	Fail if the index is not an Integer or is not the index of a fixed variable. 
	Answer the value stored as the result. Using this message violates the 
	principle that each object has sovereign control over the storing of 
	values into its instance variables. Essential. See Object documentation 
	whatIsAPrimitive."

	"Access beyond fixed fields"

	<primitive: 74>
	^ self basicAt: anInteger - self class instSize put: anObject
]

{ #category : #all }
Object >> isBehavior [
	"Answer true if I am a subclass of Behavior."

	^ false
]

{ #category : #all }
Object >> isCompiledBlock [
	^ false
]

{ #category : #all }
Object >> isCompiledMethod [
	^ false
]

{ #category : #all }
Object >> isInteger [
	"Overridden to return true in Integer."

	^ false
]

{ #category : #all }
Object >> isKindOf: aClass [
	"Answer whether the class, aClass, is a superclass or class of the receiver."

	self class == aClass
		ifTrue: [ ^ true ]
		ifFalse: [ ^ self class inheritsFrom: aClass ]
]

{ #category : #all }
Object >> isNil [
	"Answer true if the receiver is nil."

	^ false
]

{ #category : #all }
Object >> notNil [
	"Answer true if the receiver is not nil."

	^ true
]

{ #category : #all }
Object >> isNotNil [
	"Answer true if the receiver is not nil."

	^ true
]

{ #category : #all }
Object >> isNumber [
	"Overridden to return true in Number, natch"

	^ false
]

{ #category : #all }
Object >> isSmallInteger [
	^ false
]

{ #category : #all }
Object >> isString [
	^ false
]

{ #category : #all }
Object >> isSymbol [
	^ false
]

{ #category : #all }
Object >> isClass [
	^ false
]

{ #category : #all }
Object >> mustBeBoolean [
	"Error: attempt to use a non-Boolean object as if it were true or false. This message is sent by the virtual machine."

	self error: 'NonBoolean receiver.'.
	^ true
]

{ #category : #all }
Object >> nextInstance [
	"Primitive. Answer the next instance after the receiver in the enumeration of all instances of this class. Fails if all instances have been enumerated. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 78>
	^ nil
]

{ #category : #all }
Object >> nextObject [
	"Primitive. Answer the next object after the receiver in the enumeration of all objects. Answer 0 when all objects have been enumerated."

	<primitive: 139>
	self primitiveFailed
]

{ #category : #all }
Object >> perform: aSymbol [
	"Primitive. Send the receiver the unary message indicated by the 
	argument. The argument is the selector of the message. Invoke 
	messageNotUnderstood: if the number of arguments expected by the 
	selector is not zero. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 83>
	^ self perform: aSymbol withArguments: (Array new: 0)
]

{ #category : #all }
Object >> perform: aSymbol with: anObject [
	"Primitive. Send the receiver the keyword message indicated by the 
	arguments. The first argument is the selector of the message. The other 
	argument is the argument of the message to be sent. Invoke 
	messageNotUnderstood: if the number of arguments expected by the 
	selector is not one. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 83>
	^ self perform: aSymbol withArguments: (Array with: anObject)
]

{ #category : #all }
Object >> perform: selector withArguments: anArray [
	"Primitive. Send the receiver the keyword message indicated by the 
	arguments. The argument, selector, is the selector of the message. The 
	arguments of the message are the elements of anArray. Invoke 
	messageNotUnderstood: if the number of arguments expected by the 
	selector is not the same as the length of anArray. Essential. See Object 
	documentation whatIsAPrimitive."

	<primitive: 84>
	selector class = Symbol
		ifFalse: [ ^ self error: 'selector argument must be a Symbol' ].
	self primitiveFailed
]

{ #category : #all }
Object >> perform: selector withArguments: argArray inSuperclass: lookupClass [
	"NOTE:  This is just like perform:withArguments: except that the message lookup process begins, not with the receivers's class, but with the supplied superclass instead. It will fail if lookupcannot be found among the receiver's superclasses. Primitive. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 100>
	selector class = Symbol
		ifFalse: [ ^ self error: 'selector argument must be a Symbol' ].
	selector numArgs = argArray size
		ifFalse: [ ^ self error: 'incorrect number of arguments' ].
	(self class == lookupClass
		or: [ self class inheritsFrom: lookupClass ])
		ifFalse: [ ^ self error: 'lookupClass is not in my inheritance chain' ].
	self primitiveFailed
]

{ #category : #all }
Object >> pointsTo: anObject [
	"Answer true if the receiver contains a reference to the given object."

	<primitive: 132>
	1 to: self class instSize do: [ :i | 
		(self instVarAt: i) == anObject
			ifTrue: [ ^ true ] ].
	1 to: self basicSize do: [ :i | 
		(self basicAt: i) == anObject
			ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #all }
Object >> primitiveFailed [
	"Announce that a primitive has failed."

	| origin |

	origin := thisContext sender method.

	self error: 'a primitive has failed in ', origin methodClass asString, ' >> #', origin selector asString
]

{ #category : #all }
Object >> printOn: aStream [
	"Print a description of me on the given stream."

	| n |
	n := self class name.
	aStream
		nextPutAll:
			(n first isVowel
				ifTrue: [ 'an ' ]
				ifFalse: [ 'a ' ]) , n
]

{ #category : #all }
Object >> printString [
	"Answer a string describing me."

	| stream |
	stream := WriteStream on: (String new: 100).
	self printOn: stream.
	^ stream contents
]

{ #category : #all }
Object >> respondsTo: aSymbol [
	"Answer whether the receiver's class or one of its superclasses has the given symbol as a message selector."

	^ self class canUnderstand: aSymbol
]

{ #category : #all }
Object >> shouldNotImplement [
	"Announce that, although the receiver inherits this message, it should not implement it."

	self error: 'This message is not appropriate for this object'
]

{ #category : #all }
Object >> someObject [
	"Primitive. Answer the first object in the enumeration of all objects."

	<primitive: 138>
	self primitiveFailed
]

{ #category : #all }
Object >> species [
	"Answer the preferred class for reconstructing the receiver, which is typically some kind of collection. For example, the response to this message determines the type of object returned by the collect: or select: messages. Species and class are not always the same. For example, the species of Interval is Array."

	^ self class
]

{ #category : #all }
Object >> subclassResponsibility [
	"This message sets up a framework for the behavior of subclasses of this class. Announce that the subclass should have implemented this message."

	self error: 'My subclass should have overridden one of my messages.'
]

{ #category : #all }
Object >> tryPrimitive: primIndex withArgs: argumentArray [
	"This method is a template that the Smalltalk simulator uses to 
	execute primitives. See Object documentation whatIsAPrimitive."

	<primitive: 118 error: #code>
	self primitiveFailed
]

{ #category : #all }
Object >> yourself [
	"Answer the receiver. Useful in cascaded message expressions."

	^ self
]

{ #category : #all }
Object >> value [

	^ self
]

{ #category : #all }
Object >> ~= anObject [
	"Answer whether the receiver and the argument do not represent the same object."

	^ self = anObject == false
]

{ #category : #all }
Object >> ~~ anObject [
	"Answer whether the receiver and the argument are not the same object 
	(do not have the same object pointer)."

	^ self == anObject
		ifTrue: [ false ]
		ifFalse: [ true ]
]

{ #category : #all }
Object >> isMethodProperties [
	^ false
]

{ #category : #all }
Object >> isPoint [
	^ false
]

{ #category : #all }
Object >> classVariableNamed: aSymbol [
	^ self error: 'Unknown class variable ', aSymbol printString
]

{ #category : #all }
Object >> crTrace: aString [
	File stdout
		<< aString ;
		lf ;
		flush
]

{ #category : #all }
Object >> crWarn: aString [
	File stdout
		<< 'Warning: ' ;
		<< aString ;
		lf ;
		flush
]

{ #category : #all }
Object >> crError: aString [

	File stderr
		<< 'Error: ' ;
		<< aString ;
		lf ;
		flush
]

{ #category : #all }
Object >> flag: aSymbol [
	"Ignore"
]
