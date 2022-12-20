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
		'environmentLocation',
		'startUp'
	],
	#category : #'TinyBootstrap-Core'
}

{ #category : #running }
PBTinyBootstrap class >> bootstrap [

	"Perform bootstrap using default values"

	self
		bootstrapArchitecture: 'TinyImage32'
		fromSource: './bootstrap-source'
		into: 'tiny.image'
		startUp: 'Smalltalk startUp'
		version: '1.0'
		buildNumber: 42
]

{ #category : #running }
PBTinyBootstrap class >> bootstrapArchitecture: aSymbol fromSource: sourceString into: imageNameString startUp: startString version: versionString buildNumber: anInteger [

	(self forArchitecture: aSymbol)
		environmentLocation: sourceString ;
		imageName: imageNameString ;
		startUp: startString ;
		versionInfo: (PBVersionInfo fromSemanticVersion: versionString) ;
		buildNumber: anInteger ;
		bootstrap
]

{ #category : #'instance creation' }
PBTinyBootstrap class >> for32Bits [

	^ self forArchitecture: 'TinyImage32'
]

{ #category : #'instance creation' }
PBTinyBootstrap class >> for64Bits [

	^ self forArchitecture: 'TinyImage64'
]

{ #category : #bootstrapping }
PBTinyBootstrap >> createImage [

	"Create image.

	Implementation:
	Special variant for tiny image. This method should be exact copy of
	superclass' implementation in which only required changes are made.
	(The changes are commented with 'TI' - Tiny Image)."

	| builder |

	builder := PBImageBuilderSpur50 forAnyArchitecture: architecture.		"TI: Use #forAnyArchitecture: which can find the correct builder"
	builder startUp: startUp.															"TI: Set the start up code for the image"
	builder versionInfo: versionInfo.
	builder imageFileReference: imageReference.
	builder systemDefinition: ringEnvironment.
	builder espellBackend instanceVariableMapping: (PBInstanceVariableMapping onEnvironment: ringEnvironment ).
		
	builder bootstrap
]

{ #category : #preparation }
PBTinyBootstrap >> createRingEnvironment [

	ringEnvironment := RGEnvironment fromTonelRepositoryAtUrl: 'tonel://', environmentLocation.

	ringEnvironment
		fixProtoObjectClassSuperclass ;
		fixCompiledBlockLayout ;
		cleanGlobalVariables ;
		addGlobalsNamed: #(#Smalltalk #Undeclared #Processor) ;
		clean
]

{ #category : #accessing }
PBTinyBootstrap >> environmentLocation: aString [

	"Set the location for the environment where the source code is stored"

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

{ #category : #accessing }
PBTinyBootstrap >> startUp: aString [

	"Set the String which contains the start up code"

	startUp := aString
]
