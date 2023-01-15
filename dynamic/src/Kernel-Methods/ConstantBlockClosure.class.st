Class {
	#name : #ConstantBlockClosure,
	#superclass : #CleanBlockClosure,
	#type : #variable,
	#instVars : [
		'literal'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
ConstantBlockClosure class >> numArgs: anInteger literal: anObject [
	^ self new
		numArgs: anInteger ;
		literal: anObject ;
		yourself
]

{ #category : #all }
ConstantBlockClosure >> literal [
	^ literal
]

{ #category : #all }
ConstantBlockClosure >> literal: anObject [
	literal := anObject
]

{ #category : #all }
ConstantBlockClosure >> value [

	numArgs = 0 ifFalse: [ self error: 'ConstantBlockClosure evaluated without arguments, but ', numArgs printString, ' expected.' ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> value: anObject [

	numArgs = 1 ifFalse: [ self error: 'ConstantBlockClosure evaluated with 1 argument, but ', numArgs printString, ' expected.' ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> value: firstObject value: secondObject [

	numArgs = 2 ifFalse: [ self error: 'ConstantBlockClosure evaluated with 2 arguments, but ', numArgs printString, ' expected.' ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> value: firstObject value: secondObject value: thirdObject [

	numArgs = 3 ifFalse: [ self error: 'ConstantBlockClosure evaluated with 3 arguments, but ', numArgs printString, ' expected.' ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> value: firstObject value: secondObject value: thirdObject value: fourthObject [

	numArgs = 4 ifFalse: [ self error: 'ConstantBlockClosure evaluated with 4 arguments, but ', numArgs printString, ' expected.' ].

	^ literal
]

{ #category : #all }
ConstantBlockClosure >> valueWithArguments: anArray [

	numArgs = anArray size ifFalse: [ self error: 'ConstantBlockClosure evaluated with ', anArray size printString, ' arguments, but ', numArgs printString, ' expected.' ].

	^ literal
]
