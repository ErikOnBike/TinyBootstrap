Extension { #name : #PBImageBuilderSpur50 }

{ #category : #'*TinyBootstrap' }
PBImageBuilderSpur50 class >> forAnyArchitecture: architecture [

	"Select the correct subclass for the specified architecture (String).

	Implementation:
	Special variant for tiny image. This method should be exact copy of
	superclass' implementation of #forArchitecture: in which only required
	changes are made.
	(The changes are commented with 'TI' - Tiny Image)."

	| candidates |
	candidates := self allSubclasses select: [ :sc | sc name endsWith: architecture, 'bit' ].			"TI: Use #allSubclasses to allow correct subclass to be selected"
	
	candidates 
		ifEmpty: [ self error: 'No candidates for architecture: ', architecture ].
	candidates size > 1
		ifTrue: [ self error: 'More than one candidate for architecture: ', architecture ].
		
	^ candidates anyOne new
]
