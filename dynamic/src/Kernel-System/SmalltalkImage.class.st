Class {
	#name : #SmalltalkImage,
	#superclass : #Object,
	#instVars : [
		'globals',
		'specialObjectsArray',
		'wordSize'
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
	^ wordSize ifNil: [ wordSize := self getVMParameters at: 40 ifAbsent: [ 4 ] ].
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
	"parameterIndex is a positive integer corresponding to one of the VM's internal
	parameter/metric registers.  Answer with the current value of that register.
	Fail if parameterIndex has no corresponding register.

	VM parameters are numbered as follows:

		1	end (v3)/size(Spur) of old-space (0-based, read-only)
		2	end (v3)/size(Spur) of young/new-space (read-only)
		3	end (v3)/size(Spur) of heap (read-only)
		4	nil (was allocationCount (read-only))
		5	nil (was allocations between GCs (read-write)
		6	survivor count tenuring threshold (read-write)
		7	full GCs since startup (read-only)
		8	total milliseconds in full GCs since startup (read-only)
		9	incremental GCs (SqueakV3) or scavenges (Spur) since startup (read-only)
		10	total milliseconds in incremental GCs (SqueakV3) or scavenges (Spur) since startup (read-only)
		11	tenures of surving objects since startup or reset (read-write)
		12-20 were specific to ikp's JITTER VM, now 12-15 are open for use
		16	total microseconds at idle since start-up (if non-zero)
		17	fraction of the code zone to use (Sista only; used to control code zone use to preserve sendAndBranchData on counter tripped callback)
		18	total milliseconds in compaction phase of full GC since start-up (Spur only)
		19	scavenge threshold, the effective size of eden.  When eden fills to the threshold a scavenge is scheduled. Newer Spur VMs only.
		20	utc microseconds at VM start-up (actually at time initialization, which precedes image load).
		21	root/remembered table size (occupancy) (read-only)
		22	root table overflows since startup (read-only)
		23	bytes of extra memory to reserve for VM buffers, plugins, etc (stored in image file header).
		24	memory threshold above which shrinking object memory (rw)
		25	memory headroom when growing object memory (rw)
		26	interruptChecksEveryNms - force an ioProcessEvents every N milliseconds (rw)
		27	number of times mark loop iterated for current IGC/FGC (read-only) includes ALL marking
		28	number of times sweep loop iterated for current IGC/FGC (read-only)
		29	number of times make forward loop iterated for current IGC/FGC (read-only)
		30	number of times compact move loop iterated for current IGC/FGC (read-only)
		31	number of grow memory requests (read-only)
		32	number of shrink memory requests (read-only)
		33	number of root table entries used for current IGC/FGC (read-only)
		34	Spur: bytes allocated in total since start-up or reset (read-write) (Used to be number of allocations done before current IGC/FGC (read-only))
		35	number of survivor objects after current IGC/FGC (read-only)
		36	millisecond clock when current IGC/FGC completed (read-only)
		37	number of marked objects for Roots of the world, not including Root Table entries for current IGC/FGC (read-only)
		38	milliseconds taken by current IGC (read-only)
		39	Number of finalization signals for Weak Objects pending when current IGC/FGC completed (read-only)
		40	BytesPerOop for this image
		41	imageFormatVersion for the VM
		42	number of stack pages in use
		43	desired number of stack pages (stored in image file header, max 65535)
		44	size of eden, in bytes
		45	desired size of eden, in bytes (stored in image file header)
		46	machine code zone size, in bytes (Cog only; otherwise nil)
		47	desired machine code zone size (stored in image file header; Cog only; otherwise nil)
		48	various header flags.  See getCogVMFlags.
		49	max size the image promises to grow the external semaphore table to (0 sets to default, which is 256 as of writing)
		50-51 nil; reserved for VM parameters that persist in the image (such as eden above)
		52	root/remembered table capacity
		53	number of segments (Spur only; otherwise nil)
		54	total size of free old space (Spur only, otherwise nil)
		55	ratio of growth and image size at or above which a GC will be performed post scavenge
		56	number of process switches since startup (read-only)
		57	number of ioProcessEvents calls since startup (read-only)
		58	number of ForceInterruptCheck calls since startup (read-only)
		59	number of check event calls since startup (read-only)
		60	number of stack page overflows since startup (read-only)
		61	number of stack page divorces since startup (read-only)
		62	compiled code compactions since startup (read-only; Cog only; otherwise nil)
		63	total milliseconds in compiled code compactions since startup (read-only; Cog only; otherwise nil)
		64	the number of methods that currently have jitted machine-code
		65	whether the VM supports a certain feature, MULTIPLE_BYTECODE_SETS is bit 0, IMMUTABILITY is bit 1
		66	the byte size of a stack page
		67	the max allowed size of old space (Spur only; nil otherwise; 0 implies no limit except that of the underlying platform)
		68	the average number of live stack pages when scanned by GC (at scavenge/gc/become et al) (read-write)
		69	the maximum number of live stack pages when scanned by GC (at scavenge/gc/become et al) (read-write)
		70	the vmProxyMajorVersion (the interpreterProxy VM_MAJOR_VERSION)
		71	the vmProxyMinorVersion (the interpreterProxy VM_MINOR_VERSION)
		72 total milliseconds in full GCs Mark phase since startup (read-only)
		73 total milliseconds in full GCs Sweep phase since startup (read-only, can be 0 depending on compactors)
		74 maximum pause time due to segment allocation
		75 number of JIT compiled methods since startup (read-only)
		76 total milliseconds spent on JIT compiled methods since startup (read-only)
		77 number of JIT compiled block since startup (read-only)
		78 total milliseconds spent on JIT compiled block since startup (read-only)"

	<primitive: 254>
	self primitiveFailed
]

{ #category : #all }
SmalltalkImage >> getSystemAttribute: attributeID [
	"Optional. Answer the string for the system attribute with the given
	integer ID. Answer nil if the given attribute is not defined on this
	platform. On platforms that support invoking programs from command
	lines (e.g., Unix), this mechanism can be used to pass command line
	arguments to programs written in Pharo.

	By convention, the first command line argument that is not a VM
	configuration option is considered a 'document' to be filed in. Such a
	document can add methods and classes, can contain a serialized object,
	can include code to be executed, or any combination of these.

	Currently defined attributes include:
	-1000   1000th command line argument that specify VM options
	...
	-1              first command line argument that specify VM options
      0               the full path name for currently executing VM
                       (or, on some platforms, just the path name of the VM's directory)
       1               full path name of this image (better use primImageName instead)
       2               a Pharo document to open, if any
       3               first command line argument for Pharo programs
       ...
       1000    1000th command line argument for Pharo programs
       1001    this platform's operating system 'Mac OS', 'Win32', 'unix', ...
       1002    operating system version
       1003    this platform's processor type
       1004    vm version
       1005    window system name
       1006    vm build id
       1007    Interpreter class (Cog VM only)
       1008    Cogit class (Cog VM only)
       1201    max filename length (Mac OS only)
       1202    file last error (Mac OS only)
       10001   hardware details (Win32 only)
       10002   operating system details (Win32 only)
       10003   graphics hardware details (Win32 only)"

	<primitive: 149>
	^ nil
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
