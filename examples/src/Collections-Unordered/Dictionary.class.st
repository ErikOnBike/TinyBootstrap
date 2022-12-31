Class {
	#name : #Dictionary,
	#superclass : #Set,
	#category : #'Collections-Unordered'
}

{ #category : #all }
Dictionary >> add: anAssociation [
	| index element |
	index := self findElementOrNil: anAssociation key.
	element := array at: index.
	element == nil
		ifTrue: [ self atNewIndex: index put: anAssociation ]
		ifFalse: [ element value: anAssociation value ].
	^ anAssociation
]

{ #category : #all }
Dictionary >> associationAt: key [
	^ self associationAt: key ifAbsent: [ self errorKeyNotFound ]
]

{ #category : #all }
Dictionary >> associationAt: key ifAbsent: aBlock [
	"Answer the association with the given key.
	If key is not found, return the result of evaluating aBlock."

	^ (array at: (self findElementOrNil: key))
		ifNotNil: [ :assoc | assoc ]
		ifNil: [ aBlock value ]
]

{ #category : #all }
Dictionary >> associationAt: key ifAbsentPut: aBlock [
	^ self associationAt: key ifAbsent: [ self add: aBlock value ]
]

{ #category : #all }
Dictionary >> associations [
	"Return an array whose elements are the associations of the receiver"

	| s |
	s := WriteStream on: (Array new: self size).
	self associationsDo: [ :el | s nextPut: el ].
	^ s contents
]

{ #category : #all }
Dictionary >> associationsDo: aBlock [
	"Evaluate aBlock for each of the receiver's elements (key/value 
	associations)."

	super do: aBlock
]

{ #category : #all }
Dictionary >> at: key [
	"Answer the value associated with the key."

	^ self at: key ifAbsent: [ self errorKeyNotFound ]
]

{ #category : #all }
Dictionary >> at: key ifPresent: aBlock ifAbsent: exceptionBlock [
	^ (array at: (self findElementOrNil: key)) 
		ifNil: [ exceptionBlock value ] 
		ifNotNil: [ :assoc | aBlock cull: assoc value ]
]

{ #category : #all }
Dictionary >> at: key ifAbsent: aBlock [
	^ ((array at: (self findElementOrNil: key)) 
		ifNil: [ aBlock ] 
		ifNotNil: [ :assoc | assoc ]) value.
]

{ #category : #all }
Dictionary >> at: key ifPresent: presentBlock [

	^ self at: key ifPresent: presentBlock ifAbsent: [ "ignore" ]
]

{ #category : #all }
Dictionary >> at: key ifPresent: presentBlock ifAbsentPut: absentBlock [

	^ self at: key ifPresent: presentBlock ifAbsent: [ self at: key put: absentBlock value ]
]

{ #category : #all }
Dictionary >> at: key ifAbsentPut: aBlock [
	"Answer the element at the given index. If I do not contain an element at that index, put the result of evaluating aBlock into the specified location and answer that result."

	^ self at: key ifAbsent: [ self at: key put: aBlock value ]
]

{ #category : #all }
Dictionary >> at: key put: anObject [
	"Set the value at key to be anObject.  If key is not found, create a new
	entry for key and set is value to anObject. Answer anObject."

	| index element |
	index := self findElementOrNil: key.
	element := array at: index.
	element == nil
		ifTrue:
			[ self atNewIndex: index put: (Association key: key value: anObject) ]
		ifFalse: [ element value: anObject ].
	^ anObject
]

{ #category : #all }
Dictionary >> collect: aBlock [
	"Evaluate aBlock with each of my values as the argument. Collect the resulting values into a collection that is like me. Answer with the new collection."

	| newCollection |
	newCollection := OrderedCollection new: self size.
	self do: [ :each | newCollection add: (aBlock value: each) ].
	^ newCollection
]

{ #category : #all }
Dictionary >> postCopy [
	"Must copy all my associations or later stores into either dictionary will effect both the original and the copy."

	super postCopy.
	array withIndexDo: [ :each :index |
		each ifNotNil: [
			array
				at: index
				put: (Association key: each key value: each value) ] ]
]

{ #category : #all }
Dictionary >> do: aBlock [
	super do: [ :assoc | aBlock value: assoc value ]
]

{ #category : #all }
Dictionary >> errorKeyNotFound [
	self error: 'key not found'
]

{ #category : #all }
Dictionary >> errorValueNotFound [
	self error: 'value not found'
]

{ #category : #all }
Dictionary >> includes: anObject [
	self
		do: [ :each | 
			anObject = each
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #all }
Dictionary >> includesKey: key [
	"Answer whether the receiver has a key equal to the argument, key."

	| index |
	index := self findElementOrNil: key.
	(array at: index) == nil
		ifTrue: [ ^ false ]
		ifFalse: [ ^ true ]
]

{ #category : #all }
Dictionary >> keyAt: index [
	"May be overridden by subclasses so that fixCollisions will work"

	| assn |
	assn := array at: index.
	assn == nil
		ifTrue: [ ^ nil ]
		ifFalse: [ ^ assn key ]
]

{ #category : #all }
Dictionary >> keyAtValue: value [
	"Answer the key that is the external name for the argument, value. If 
	there is none, answer nil."

	^ self keyAtValue: value ifAbsent: [ self errorValueNotFound ]
]

{ #category : #all }
Dictionary >> keyAtValue: value ifAbsent: exceptionBlock [
	"Answer the key that is the external name for the argument, value. If 
	there is none, answer the result of evaluating exceptionBlock.
	: Use =, not ==, so stings like 'this' can be found.  Note that MethodDictionary continues to use == so it will be fast."

	self
		associationsDo: [ :association | 
			value = association value
				ifTrue: [ ^ association key ] ].
	^ exceptionBlock value
]

{ #category : #all }
Dictionary >> keyAtIdentityValue: value [
	"Answer the key that is the external name for the argument, value. If 
	there is none, answer nil."

	^ self keyAtIdentityValue: value ifAbsent: [ self errorValueNotFound ]
]

{ #category : #all }
Dictionary >> keyAtIdentityValue: value ifAbsent: exceptionBlock [
	"Answer the key that is the external name for the argument, value. If 
	there is none, answer the result of evaluating exceptionBlock.
	Note: There can be multiple keys with the same value. Only one is returned."
 
	self associationsDo: 
		[:association | value == association value ifTrue: [^association key]].
	^exceptionBlock value
]

{ #category : #all }
Dictionary >> keys [
	"Answer a Set containing the receiver's keys."

	| aSet |
	aSet := Set new: self size.
	self keysDo: [ :key | aSet add: key ].
	^ aSet
]

{ #category : #all }
Dictionary >> keysDo: aBlock [
	"Evaluate aBlock for each of the receiver's keys."

	self associationsDo: [ :association | aBlock value: association key ]
]

{ #category : #all }
Dictionary >> valuesDo: aBlock [
	self associationsDo: [ :association | aBlock value: association value ]
]

{ #category : #all }
Dictionary >> keysAndValuesDo: aBlock [
	self associationsDo: [ :assoc | aBlock value: assoc key value: assoc value ]
]

{ #category : #all }
Dictionary >> noCheckAdd: anObject [
	"Must be defined separately for Dictionary because (self findElementOrNil:) expects a key, not an association.  9/7/96 tk"

	array at: (self findElementOrNil: anObject key) put: anObject.
	tally := tally + 1
]

{ #category : #all }
Dictionary >> printOn: aStream [
	aStream nextPutAll: self class name , ' ('.
	self
		associationsDo: [ :element | 
			element printOn: aStream.
			aStream space ].
	aStream nextPut: $)
]

{ #category : #all }
Dictionary >> remove: anObject [
	self shouldNotImplement
]

{ #category : #all }
Dictionary >> remove: anObject ifAbsent: exceptionBlock [
	self shouldNotImplement
]

{ #category : #all }
Dictionary >> removeKey: key [
	"Remove key from the receiver.
	If key is not in the receiver, notify an error."

	^ self removeKey: key ifAbsent: [ self errorKeyNotFound ]
]

{ #category : #all }
Dictionary >> removeKey: key ifAbsent: aBlock [
	"Remove key (and its associated value) from the receiver. If key is not in 
	the receiver, answer the result of evaluating aBlock. Otherwise, answer 
	the value externally named by key."

	| index assoc |
	index := self findElementOrNil: key.
	assoc := array at: index.
	assoc == nil
		ifTrue: [ ^ aBlock value ].
	array at: index put: nil.
	tally := tally - 1.
	self fixCollisionsFrom: index.
	^ assoc value
]

{ #category : #all }
Dictionary >> removeAllSuchThat: aBlock [
	"Evaluate aBlock for each element and remove all that elements from
	the receiver for that aBlock evaluates to true.  Use a copy (in the form of
	the associations) to allow updating the receiver while iterating."

	self associations do: [:each | (aBlock value: each value) ifTrue: [self removeKey: each key ] ]
]

{ #category : #all }
Dictionary >> scanFor: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or zero if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."

	| element start finish |
	start := anObject hash \\ array size + 1.
	finish := array size.	"Search from (hash mod size) to the end."
	start to: finish do: [ :index | 
		((element := array at: index) == nil or: [ element key = anObject ])
			ifTrue: [ ^ index ] ].	"Search from 1 to where we started."
	1 to: start - 1 do: [ :index | 
		((element := array at: index) == nil or: [ element key = anObject ])
			ifTrue: [ ^ index ] ].
	^ 0	"No match AND no empty slot"
]

{ #category : #all }
Dictionary >> select: aBlock [
	"Evaluate aBlock with each of my values as the argument. Collect into a
	new dictionary, only those associations for which aBlock evaluates to
	true."

	| newCollection |
	newCollection := self species new.
	self
		associationsDo: [ :each | 
			(aBlock value: each value)
				ifTrue: [ newCollection add: each ] ].
	^ newCollection
]
