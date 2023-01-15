Class {
	#name : #AdditionalMethodState,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'method',
		'selector'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
AdditionalMethodState >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #all }
AdditionalMethodState >> selector [
	^ selector
]

{ #category : #all }
AdditionalMethodState >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #all }
AdditionalMethodState >> pragmas [

	| pragmas |

	pragmas := Array new: self basicSize.
	1 to: self basicSize do: [ :index |
		pragmas at: index put: (self basicAt: index) ].

	^ pragmas
]

{ #category : #all }
AdditionalMethodState >> at: aKey [
	^ self at: aKey ifAbsent: [ self error: 'not found' ]
]

{ #category : #all }
AdditionalMethodState >> at: aKey ifAbsent: aBlock [

	| pragma |

	1 to: self basicSize do: [ :index |
		(pragma := self basicAt: index) key == aKey
			ifTrue: [ ^ pragma ] ].

	^ aBlock value
]

{ #category : #all }
AdditionalMethodState >> includes: aPragma [

	1 to: self basicSize do: [ :index |
		(self basicAt: index) == aPragma
			ifTrue: [ ^ true ] ].

	^ false
]

{ #category : #all }
AdditionalMethodState >> includesKey: aSymbol [

	1 to: self basicSize do: [ :index |
		(self basicAt: index) key == aSymbol
			ifTrue: [ ^ true ] ].

	^ false
]

{ #category : #all }
AdditionalMethodState >> isEmpty [
	^ self basicSize = 0
]

{ #category : #all }
AdditionalMethodState >> notEmpty [
	^ self basicSize > 0
]

{ #category : #all }
AdditionalMethodState >> setMethod: aCompiledMethod [

	self method: aCompiledMethod.
	1 to: self basicSize do: [ :index |
		(self basicAt: index) method: aCompiledMethod ]
]

{ #category : #all }
AdditionalMethodState >> isMethodProperties [
	^ true
]
