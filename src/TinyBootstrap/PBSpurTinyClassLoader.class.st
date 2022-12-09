"
I am a bootstrap Class loader and responsible for creating and loading classes
into the bootstrap image. I know how classes are loaded in a tiny image.
"
Class {
	#name : #PBSpurTinyClassLoader,
	#superclass : #PBSpurClassLoader,
	#instVars : [
		'metaclassThisClassIndex'
	],
	#category : #'TinyBootstrap-Core'
}

{ #category : #stubs }
PBSpurTinyClassLoader >> classDefinitionFor: aClass [

	"Answer a String that defines the receiver."

	| type |

	type := 	aClass isImmediateClass
		ifTrue: [ 'beImmediate' ]
		ifFalse: [
			aClass isWeak
				ifTrue: [ 'beWeak' ]
				ifFalse: [
					aClass isPointers
						ifTrue: [
							aClass isVariable
								ifTrue: [ 'beVariable' ]
								ifFalse: [ 'yourself' ] ]
						ifFalse: [
							aClass isCompiledMethod
								ifTrue: [ 'beCompiledMethod' ]
								ifFalse: [
									aClass isWords
										ifTrue: [ 'beWords' ]
										ifFalse: [ 'beBytes' ] ] ] ] ].

	^ '({classBuilder} new
			superclass: {superClass};
			name: #{name};
			instVarNames: {instanceVariablesString};
			classVariableNames: {classVariablesString};
			yourself)
		{type};
		build'
	format: {
			'classBuilder' -> (systemDefinition classNamed: #ClassBuilder).
			'superClass' -> (aClass superclass ifNil: [ 'nil' ] ifNotNil: [ :superclass | superclass name ]).
			'name' -> aClass name.
			'type' -> type.
			'instanceVariablesString' -> ('#(', (' ' join: aClass instVarNames), ')').
			'classVariablesString' -> aClass classVariableDefinitionString } asDictionary
]

{ #category : #initialization }
PBSpurTinyClassLoader >> initializeClassPool: aClassName [

	"Initialize the class pool for the specified class.

	Implementation:
	Special variant for tiny image in which a number of classes is not
	present and therefore creation is not possible.
	This method should be exact copy of superclass' implementation in
	which only required changes are made.
	(The changes are commented with 'TI' - Tiny Image)."

	| definition class classPool classVariableBindings |
	definition := systemDefinition classNamed: aClassName.
	class := environment at: aClassName.

	classVariableBindings := definition classVarNames collect: [ :each | | classVar |
		"classVar := (self classNamed: #ClassVariable) basicNew."								"TI: ClassVariable does not exist, use Association"
		classVar := (self classNamed: #Association) basicNew.
		classVar instanceVariableAtIndex: 1 put: (each asLiteralInObjectSpace: builder objectSpace).
		"classVar instanceVariableAtIndex: 3 put: class" "initialize owningClass"			"TI: No owningClass present in Association, ignore"
		classVar ].
	
	"class := environment at: aClassName."															"TI: Was already set at top of method (useless assignment in original code)"
	classPool := builder bootstrapInterpreter
		evaluateCode: 'aClassVariableNamesCollection asDictionary'
		withTemps: { 
			'aClassVariableNamesCollection' -> (builder objectSpace newArrayWithAll: classVariableBindings)
		}.
	
	"Force the creation of the symbol using the object space class table." 
	self flag: #bug. "If we do not use basicSetClassName, we duplicate symbols"
	class basicSetClassName: (aClassName asLiteralInObjectSpace: builder objectSpace).
	class classPool: classPool.
	^ class
]
