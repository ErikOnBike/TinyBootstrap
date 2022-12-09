"
I am the bootstrap class responsible for creating a tiny image.

Do be able to create a tiny image, bootstrap source code should be
provided. This can either be in the default 'bootstrap-source' directory
(under the root of the Pharo execution environment) or explicitly
specified using a (relative or absolute) directory reference.

Example usage:

""All default values""
PBTinyBoostrap bootstrap.

""All explicit values""
PBTinyBootstrap
		bootstrpFromSource: '../boot-source-code/'
		into: '../boot-target-image/target.image'
		version: '1.0.1'
		buildNumber: 42.

"
Class {
	#name : #PBTinyBootstrap,
	#superclass : #PBBootstrap,
	#instVars : [
		'environmentLocation'
	],
	#category : #'TinyBootstrap-Core'
}

{ #category : #running }
PBTinyBootstrap class >> bootstrap [

	"Perform bootstrap using default values (source location will be './bootstrap-source')"

	self bootstrapFromSource: nil into: 'tiny.image' version: '1.0' buildNumber: 42
]

{ #category : #running }
PBTinyBootstrap class >> bootstrapFromSource: sourceString into: imageNameString version: versionString buildNumber: anInteger [

	self for32Bits
		environmentLocation: sourceString ;
		imageName: imageNameString ;
		versionInfo: (PBVersionInfo fromSemanticVersion: versionString) ;
		buildNumber: anInteger ;
		bootstrap
]

{ #category : #'instance creation' }
PBTinyBootstrap class >> for32Bits [

	^ self new
]

{ #category : #'instance creation' }
PBTinyBootstrap class >> for64Bits [

	self error: 'Currently 64bit tiny images are not supported'
]

{ #category : #'instance creation' }
PBTinyBootstrap class >> new [

	^ self forArchitecture: 'Tiny'
]

{ #category : #preparation }
PBTinyBootstrap >> createRingEnvironment [

	ringEnvironment := RGEnvironment fromTonelRepositoryAtUrl: 'tonel://', self environmentLocation.

	ringEnvironment
		fixProtoObjectClassSuperclass ;
		fixCompiledBlockLayout ;
		cleanGlobalVariables ;
		addGlobalsNamed: #(#Smalltalk #Undeclared #Processor) ;
		clean
]

{ #category : #accessing }
PBTinyBootstrap >> environmentLocation [

	^ environmentLocation ifNil: [ './bootstrap-source' ]
]

{ #category : #accessing }
PBTinyBootstrap >> environmentLocation: aString [

	environmentLocation := aString
]

{ #category : #accessing }
PBTinyBootstrap >> imageName: aString [

	"Create a FileReference to the file name specified (in the current directory).
	Do not store in the 'bootstrap-cache' directory as is the default implementation."

	imageReference := './' asFileReference / aString
]

{ #category : #preparation }
PBTinyBootstrap >> prepareBootstrap [

	"Prepare for bootstrap.

	Implementation:
	Override the superclass' version completely.
	No exports are made (no need for them)."

	self createRingEnvironment
]
