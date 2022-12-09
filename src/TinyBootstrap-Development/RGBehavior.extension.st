Extension { #name : #RGBehavior }

{ #category : #'*TinyBootstrap-Development' }
RGBehavior >> buildMicroDownUsing: aBuilder withComment: aString [

	aBuilder
		header: [ aBuilder text: 'Class: ' ; text: self name ] withLevel: 1 ;
		horizontalLine ;
		text: aString
]

{ #category : #'*TinyBootstrap-Development' }
RGBehavior >> classVariablesOn: aStream [

	aStream nextPutAll: self classVariablesString
]

{ #category : #'*TinyBootstrap-Development' }
RGBehavior >> definitionString [

	^ (ClassDefinitionPrinter for: self) definitionString
]

{ #category : #'*TinyBootstrap-Development' }
RGBehavior >> instanceVariablesOn: aStream [

	self slots
		do: [ :each | aStream nextPutAll: each name asString]
		separatedBy: [ aStream space ]
]

{ #category : #'*TinyBootstrap-Development' }
RGBehavior >> isAbstract [

	"By default a Class is not abstract"

	^ false
]

{ #category : #'*TinyBootstrap-Development' }
RGBehavior >> needsSlotClassDefinition [

	^ self slotsNeedFullDefinition
]

{ #category : #'*TinyBootstrap-Development' }
RGBehavior >> visibleMethods [

	^ self methods
]
