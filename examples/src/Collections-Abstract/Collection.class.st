Class {
	#name : #Collection,
	#superclass : #Object,
	#category : #'Collections-Abstract'
}

{ #category : #all }
Collection class >> with: anObject [
	"Answer an instance of me containing anObject."

	| newCollection |
	newCollection := self new.
	newCollection add: anObject.
	^ newCollection
]

{ #category : #all }
Collection class >> with: firstObject with: secondObject [
	"Answer an instance of me containing the two arguments as elements."

	| newCollection |
	newCollection := self new.
	newCollection add: firstObject.
	newCollection add: secondObject.
	^ newCollection
]

{ #category : #all }
Collection class >> with: firstObject with: secondObject with: thirdObject [
	"Answer an instance of me containing the three arguments as elements."

	| newCollection |
	newCollection := self new.
	newCollection add: firstObject.
	newCollection add: secondObject.
	newCollection add: thirdObject.
	^ newCollection
]

{ #category : #all }
Collection class >>  withAll: aCollection [
	"Create a new collection containing all the elements from aCollection."

	^ (self new: aCollection size)
		addAll: aCollection;
		yourself
]

{ #category : #all }
Collection >> add: newObject [
	"Include newObject as one of my elements. Answer newObject. ArrayedCollections cannot respond to this message."

	self subclassResponsibility
]

{ #category : #all }
Collection >> addAll: aCollection [
	"Include all the elements of aCollection as the receiver's elements. Answer 
	aCollection. Actually, any object responding to #do: can be used as argument."

	aCollection do: [:each | self add: each].
	^ aCollection
]

{ #category : #all }
Collection >> asArray [
	"Answer an Array whose elements are the elements of this collection. The order in which elements are added depends on the order in which this collection enumerates its elements. In the case of unordered collections, the ordering is not necessarily the same for multiple requests for the conversion."

	| result i |
	result := Array new: self size.
	i := 0.
	self do: [ :each | result at: (i := i + 1) put: each ].
	^ result
]

{ #category : #all }
Collection >> asByteArray [
	"Answer a ByteArray containing my elements."

	| result i |
	result := ByteArray new: self size.
	i := 0.
	self do: [ :each | result at: (i := i + 1) put: each ].
	^ result
]

{ #category : #all }
Collection >> asSet [
	"Answer a Set whose elements are the unique elements of the receiver."

	| aSet |
	aSet := Set new: self size.
	self do: [ :each | aSet add: each ].
	^ aSet
]

{ #category : #all }
Collection >> collect: aBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Collect the resulting values into a collection like the receiver. Answer 
	the new collection."

	| newCollection |
	newCollection := self species new.
	self do: [ :each | newCollection add: (aBlock value: each) ].
	^ newCollection
]

{ #category : #all }
Collection >> detect: aBlock ifNone: exceptionBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Answer the first element for which aBlock evaluates to true. If none 
	evaluate to true, then evaluate the argument, exceptionBlock."

	self
		do: [ :each | 
			(aBlock value: each)
				ifTrue: [ ^ each ] ].
	^ exceptionBlock value
]

{ #category : #all }
Collection >> detect: aBlock ifFound: foundBlock ifNone: exceptionBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument.
	If some element evaluates aBlock to true, then cull this element into
	foundBlock and answer the result of this evaluation.
	If none evaluate to true, then evaluate exceptionBlock."

	self
		do: [ :each |
			(aBlock value: each)
				ifTrue: [ ^ foundBlock cull: each ] ].
	^ exceptionBlock value
]

{ #category : #all }
Collection >> do: aBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument."

	self subclassResponsibility
]

{ #category : #all }
Collection >> emptyCheck [
	self isEmpty
		ifTrue: [ self errorEmptyCollection ]
]

{ #category : #all }
Collection >> errorEmptyCollection [
	self error: 'this collection is empty'
]

{ #category : #all }
Collection >> errorNotFound [
	self error: 'Object is not in the collection.'
]

{ #category : #all }
Collection >> includes: anObject [
	"Answer whether anObject is one of the receiver's elements."

	self
		do: [ :each | 
			anObject = each
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #all }
Collection >> isEmpty [
	"Answer whether the receiver contains any elements."

	^ self size = 0
]

{ #category : #all }
Collection >> isNotEmpty [
	"Answer whether the receiver does not contain any elements."

	^ self isEmpty not
]

{ #category : #all }
Collection >> notEmpty [
	"Answer whether the receiver does not contain any elements."

	^ self isEmpty not
]

{ #category : #all }
Collection >> ifEmpty: aBlock [
	^ self isEmpty
		ifTrue: [ aBlock value ]
		ifFalse: [ self ]
]

{ #category : #all }
Collection >> ifNotEmpty: aBlock [
	^ self isEmpty
		ifTrue: [ self ]
		ifFalse: [ aBlock cull: self ]
]

{ #category : #all }
Collection >> ifEmpty: emptyBlock ifNotEmpty: notEmptyBlock [
	^ self isEmpty
		ifTrue: [ emptyBlock value ]
		ifFalse: [ notEmptyBlock cull: self ]
]

{ #category : #all }
Collection >> ifNotEmpty: notEmptyBlock ifEmpty: emptyBlock [
	^ self isEmpty
		ifTrue: [ emptyBlock value ]
		ifFalse: [ notEmptyBlock cull: self ]
]

{ #category : #all }
Collection >> printOn: aStream [
	"Refer to the comment in Object|printOn:."

	aStream nextPutAll: self class name , ' ('.
	self
		do: [ :element | 
			element printOn: aStream.
			aStream space ].
	aStream nextPut: $)
]

{ #category : #all }
Collection >> remove: oldObject [
	"Remove oldObject as one of the receiver's elements. Answer oldObject 
	unless no element is equal to oldObject, in which case, create an error 
	notification."

	^ self remove: oldObject ifAbsent: [ self errorNotFound ]
]

{ #category : #all }
Collection >> remove: oldObject ifAbsent: anExceptionBlock [
	"Remove oldObject as one of the receiver's elements. If several of the 
	elements are equal to oldObject, only one is removed. If no element is 
	equal to oldObject, answer the result of evaluating anExceptionBlock. 
	Otherwise, answer the argument, oldObject. SequenceableCollections 
	cannot respond to this message."

	self subclassResponsibility
]

{ #category : #all }
Collection >> removeAll [
	self do: [ :each | self remove: each ]
]

{ #category : #all }
Collection >> removeAllSuchThat: aBlock [
	"Evaluate aBlock for each element and remove all that elements from
	the receiver for that aBlock evaluates to true.  Use a copy to enumerate 
	collections whose order changes when an element is removed (i.e. Sets)."

	self copy do: [:each | (aBlock value: each) ifTrue: [self remove: each ] ]
]

{ #category : #all }
Collection >> select: aBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Collect into a new collection like the receiver, only those elements for 
	which aBlock evaluates to true. Answer the new collection."

	| newCollection |
	newCollection := self species new.
	self
		do: [ :each | 
			(aBlock value: each)
				ifTrue: [ newCollection add: each ] ].
	^ newCollection
]

{ #category : #all }
Collection >> reject: aBlock [
	"Evaluate aBlock with each of the receiver's elements as the argument. 
	Collect into a new collection like the receiver, only those elements for 
	which aBlock evaluates to false. Answer the new collection."

	^ self select: [ :element | (aBlock value: element) == false ]
]

{ #category : #all }
Collection >> inject: thisValue into: binaryBlock [
	"Accumulate a running value associated with evaluating the argument, binaryBlock, with the current value of the argument, thisValue, and the receiver as block arguments."
	
	| nextValue |
	nextValue := thisValue.
	self do: [:each | nextValue := binaryBlock value: nextValue value: each].
	^nextValue
]

{ #category : #all }
Collection >> anySatisfy: aBlock [
	"Evaluate aBlock with the elements of the receiver.
	If aBlock returns true for any element return true.
	Otherwise return false"

	self do:[:item | (aBlock value: item) ifTrue: [^ true]].
	^ false
]

{ #category : #all }
Collection >> noneSatisfy: aBlock [
	"Evaluate aBlock with the elements of the receiver.
	If aBlock returns false for all elements return true.
	Otherwise return false"

	self do: [:item | (aBlock value: item) ifTrue: [^ false]].
	^ true
]

{ #category : #all }
Collection >> size [
	"Answer how many elements the receiver contains."

	| count |
	count := 0.
	self do: [ :each | count := count + 1 ].
	^ count
]

{ #category : #all }
Collection >> sum [
	"Answer the sum of the elements of this collection. If the collection is empty, answer zero."

	"Details: Use an arbitrary element of the collection as the initial value so this method will work for collections of any kind of object that understands + and -."

	| total seed |
	total := seed := self detect: [ :x | true ] ifNone: [ ^ 0 ].
	self do: [ :el | total := total + el ].
	^ total - seed	"subtract the seed value from the total"
]
