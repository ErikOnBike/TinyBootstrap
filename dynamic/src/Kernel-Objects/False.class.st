Class {
	#name : #False,
	#superclass : #True,
	#category : #'Kernel-Objects'
}

{ #category : #all }
False >> & aBoolean [
	"Answer true if both the receiver AND the argument are true. Unlike and:, the argument is always evaluted."

	^ false
]

{ #category : #all }
False >> and: alternativeBlock [
	"Answer true if both the receiver AND the result of evaluating the given block are true. Only evaluate the given block if the receiver is true."

	^ false
]

{ #category : #all }
False >> ifFalse: falseBlock [
	"If the receiver is false, answer the result of evaluating the given block. Otherwise, answer nil. Raise an error notification if the receiver is not a boolean. Execution does not actually reach here because the expression is compiled in-line."

	^ falseBlock value
]

{ #category : #all }
False >> ifTrue: trueBlock [
	"If the receiver is true, answer the result of evaluating the given block. Otherwise, answer nil. Raise an error notification if the true is not a boolean. Execution does not actually reach here because the expression is compiled in-line."

	^ nil
]

{ #category : #all }
False >> ifTrue: trueBlock ifFalse: falseBlock [
	"If the receiver is true, answer the result of evaluating trueBlock. Otherwise, answer the result of evaluating falseBlock. Raise an error notification if the receiver is not a boolean. Execution does not actually reach here because this message is compiled in-line."

	^ falseBlock value
]

{ #category : #all }
False >> not [
	"Answer the negation of the receiver."

	^ true
]

{ #category : #all }
False >> or: alternativeBlock [
	"Answer true if either the receiver OR the argument are true. Only evaluate the given block if the receiver is false."

	^ alternativeBlock value
]

{ #category : #all }
False >> printOn: aStream [
	aStream nextPutAll: 'false'
]

{ #category : #all }
False >> | aBoolean [
	"Answer true if either the receiver OR the argument are true. Unlike or:, the argument is always evaluted."

	^ aBoolean
]
