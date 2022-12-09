Extension { #name : #RGEnvironment }

{ #category : #'*TinyBootstrap' }
RGEnvironment >> allClasses [
	^ self ask behaviors
]

{ #category : #'*TinyBootstrap' }
RGEnvironment >> fixCompiledBlockLayout [

	"Fix the layout of the CompiledBlock (for bootstrapping tiny image)"

	(self allClasses detect: [ :each | each name = #CompiledBlock ])
		ifNotNil: [ :compiledBlockClass |
			compiledBlockClass layout: (RGCompiledMethodLayout parent: compiledBlockClass) ]
]

{ #category : #'*TinyBootstrap' }
RGEnvironment class >> fromTonelRepositoryAtUrl: aString [

	^ (TonelRepository basicFromUrl: aString)
		asRingEnvironment
]

{ #category : #'*TinyBootstrap' }
RGEnvironment >> packages [

	^ self ask packages
]
