Extension { #name : #EPClassMirror }

{ #category : #'*TinyBootstrap' }
EPClassMirror >> instanceVariableAtIndex: index [

	"Fix since tiny image classes do not have shared pools"
	(index isNil and: [ thisContext sender methodSelector = #sharedPools ])
		ifTrue: [ ^ backend nilObject ].

	^ super instanceVariableAtIndex: index
]
