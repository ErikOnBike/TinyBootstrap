Class {
	#name : #SmalltalkImage,
	#superclass : #Object,
	#instVars : [
		'globals',
		'specialObjectsArray'
	],
	#category : #'Kernel-System'
}

{ #category : #all }
SmalltalkImage >> at: aSymbol [
	^ self at: aSymbol ifAbsent: [ nil ]
]

{ #category : #all }
SmalltalkImage >> at: aSymbol ifAbsent: aBlock [
	^ globals at: aSymbol ifAbsent: aBlock
]

{ #category : #all }
SmalltalkImage >> at: aSymbol put: aGlobalObject [
	globals at: aSymbol put: aGlobalObject
]

{ #category : #all }
SmalltalkImage >> globalAssociationAt: aSymbol [
	^ globals associationAt: aSymbol ifAbsent: [ self error: 'Unknown global ', aSymbol printString ]
]

{ #category : #all }
SmalltalkImage >> globalAssociationAt: aSymbol ifAbsentPut: absentBlock [
	^ globals associationAt: aSymbol ifAbsentPut: absentBlock
]

{ #category : #all }
SmalltalkImage >> classNamed: aSymbol [
	| global |

	global := self at: aSymbol.
	^ global ifNotNil: [
		global isBehavior
			ifTrue: [ global ]
			ifFalse: [ nil ] ]
]

{ #category : #all }
SmalltalkImage >> globals [
	^ globals
]

{ #category : #all }
SmalltalkImage >> wordSize [
	^ 4
]

{ #category : #all }
SmalltalkImage >> registerExternalObject: anObject [

	| externalObjects index |
	externalObjects := specialObjectsArray at: 39.

	"Iterate over external objects finding first empty slot"
	index := 1.
	[ (index <= externalObjects size) and: [
		| obj |
		obj := externalObjects at: index.

		"Fake slot is empty if it is the same object as being registered"
		obj = anObject
			ifTrue: [ obj := nil ].
		obj notNil ] ] whileTrue: [
			index := index + 1 ].

	"If no slots are found, stop"
	(index <= externalObjects size)
		ifFalse: [ ^nil ].

	externalObjects at: index put: anObject.
	^ index
]

{ #category : #all }
SmalltalkImage >> unregisterExternalObject: anObject [

	| externalObjects |

	externalObjects := specialObjectsArray at: 39.
	1 to: externalObjects size do: [ :eachIndex |
		(externalObjects at: eachIndex) = anObject
			ifTrue: [ externalObjects at: eachIndex put: nil ] ]
]

{ #category : #all }
SmalltalkImage >> specialObjectsArray [
	^ specialObjectsArray
]

{ #category : #all }
SmalltalkImage >> specialObjectsArray: anArray [
	specialObjectsArray := anArray
]

{ #category : #all }
SmalltalkImage >> primitiveGetSpecialObjectsArray [
	"Answer the virtual machine's special objects array."

	<primitive: 129>
	self primitiveFailed
]

{ #category : #all }
SmalltalkImage >> getVMParameters [
	"Answer an Array containing the current values of the VM's internal parameter and statistics registers. The same primitive can be called with one integer argument to read a specific parameter and with two parameters to set a writable parameter, although these variations may not be implemented. Optional."

	"VM parameters are numbered as follows:
		1	end of old-space (0-based, read-only)
		2	end of young-space (read-only)
		3	end of memory (read-only)
		4	allocationCount (read-only)
		5	allocations between GCs (read-write)
		6	survivor count tenuring threshold (read-write)
		7	full GCs since startup (read-only)
		8	total milliseconds in full GCs since startup (read-only)
		9	incremental GCs since startup (read-only)
		10	total milliseconds in incremental GCs since startup (read-only)
		11	tenures of surving objects since startup (read-only)
		12-20 specific to the translating VM (obsolete)
		21   root table size (read-only)
		22   root table overflows since startup (read-only)"

	<primitive: 254>
	self primitiveFailed
]

{ #category : #all }
SmalltalkImage >> garbageCollect [
	"Primitive. Reclaims all garbage and answers the number of bytes of available space."

	<primitive: 130>
	self primitiveFailed
]

{ #category : #all }
SmalltalkImage >> incrementalGarbageCollect [
	"Primitive. Reclaims recently created garbage fairly quickly and answers the number of bytes of available space."

	<primitive: 131>
]

{ #category : #all }
SmalltalkImage >> allObjectsDo: aBlock [
	"Evaluate the argument, aBlock, for each object in the system excluding SmallIntegers."

	| object |
	object := self someObject.
	[ 0 == object ]
		whileFalse: [ aBlock value: object.
			object := object nextObject ]
]

{ #category : #all }
SmalltalkImage >> exitToDebugger [
	"Tell the VM that we've encountered an unhandled error or halt."

	<primitive: 114>
]

{ #category : #all }
SmalltalkImage >> quit [
	"Exit from the system."

	<primitive: 113>
]

{ #category : #all }
SmalltalkImage >> snapshot [
	self snapshotPrimitive
]

{ #category : #all }
SmalltalkImage >> snapshotAndQuit [
	| snapshotResult isImageStarting |
	snapshotResult := self snapshotPrimitive.	"<--  frozen here on image file"
	isImageStarting := (snapshotResult == true).
	isImageStarting ifFalse: [ self quit ]
]

{ #category : #all }
SmalltalkImage >> snapshotPrimitive [
	"Primitive. Write the current state of the object memory on a file in the
	same format as the Smalltalk-80 release. The file can later be resumed,
	returning you to this exact state. Return normally after writing the file.
	Essential. See Object documentation whatIsAPrimitive."

	"I will return
		true if the image is starting or
		false if the image is just resuming"

	<primitive: 97>
	^nil "indicates error writing image file"
]
