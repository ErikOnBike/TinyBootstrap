Extension { #name : #TonelRepository }

{ #category : #'*TinyBootstrap' }
TonelRepository >> allPackageNames [

	"Answer all my package names.

	Implementation:
	Use the directory names which should match the package name.
	The directory name is the first field of the description Array."

	^ self packageDescriptionsFromReadableFileNames
		collect: [ :each | each first ]
]

{ #category : #'*TinyBootstrap' }
TonelRepository >> asRingEnvironment [

	"Answer a new RingEnvironment matching all my packages"

	^ self asRingEnvironmentWith: self allPackageNames cleaning: true
]
