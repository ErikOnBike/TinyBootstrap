Class {
	#name : #File,
	#superclass : #Object,
	#instVars : [
		'id'
	],
	#category : #'Kernel-System'
}

{ #category : #all }
File class >> open: fileName writable: writableFlag [
	| id |
	id := self primOpen: fileName writable: writableFlag.
	id
		ifNotNil: [
			^ self basicNew
				initializeWithId: id ;
				yourself ]
		ifNil: [ self error: 'Failed to open file named ', fileName printString ]
]

{ #category : #all }
File class >> createDirectory: aString [
	"Create a directory named by the given path. 
	Fail if the path is bad or if a file or directory by that name already exists."

 	<primitive: 'primitiveDirectoryCreate' module: 'FilePlugin'>
	^ nil
]

{ #category : #all }
File class >> deleteDirectory: aString [
	"Delete the directory named by the given path. 
	Fail if the path is bad or if a directory by that name does not exist."

 	<primitive: 'primitiveDirectoryDelete' module: 'FilePlugin'>
	self primitiveFailed
]

{ #category : #all }
File class >> deleteFile: aString [
	"Delete the file of the given name. 
	Return self if the primitive succeeds, nil otherwise."

	<primitive: 'primitiveFileDelete' module: 'FilePlugin'>
	^ nil
]

{ #category : #all }
File class >> lookupDirectory: fullPath filename: fileName [
	"Look up <fileName> (a simple file name) in the directory identified by <fullPath> and return an array containing:

	<fileName> 			
	<creationTime> 			(in seconds since the start of the Smalltalk time epoch)
	<modificationTime> 	(in seconds since the start of the Smalltalk time epoch)
	<dirFlag> 				DirFlag is true if the entry is a directory
	<fileSize> 				FileSize the file size in bytes or zero for directories
	<posixPermissions> 	Numeric Notation 
	<symLinkFlag>			seemingly, symLinkFlag is true if the entry is a symLink

	On Unix, the empty path denotes '/'. 
	On Macs and PCs, it is the container of the system volumes."

 	<primitive: 'primitiveDirectoryEntry' module: 'FilePlugin'>
	self primitiveFailed
]

{ #category : #all }
File class >> lookupEntryIn: fullPath index: index [
	"Look up the index-th entry of the directory with the given fully-qualified path 
	(i.e., starting from the root of the file hierarchy) and return an array containing:

	<name> <creationTime> <modificationTime> <dirFlag> <fileSize>

	The empty string enumerates the top-level files or drives. (For example, on Unix, the empty 
	path enumerates the contents of '/'. On Macs and PCs, it enumerates the mounted volumes/drives.)

	The creation and modification times are in seconds since the start of the Smalltalk time epoch. 
	DirFlag is true if the entry is a directory. FileSize the file size in bytes or zero for directories. 
	The primitive returns nil when index is past the end of the directory. It fails if the given path 
	is bad."

 	<primitive: 'primitiveDirectoryLookup' module: 'FilePlugin' error: errorCode>
	self primitiveFailed
]

{ #category : #all }
File class >> rename: oldFileFullName to: newFileFullName [
	"Rename the file of the given name to the new name. Fail if there is no file of the old name 
	or if there is an existing file with the new name."

	<primitive: 'primitiveFileRename' module: 'FilePlugin'>
	self primitiveFailed
]

{ #category : #all }
File class >> stdin [
	^ self stdioHandle: #stdin
]

{ #category : #all }
File class >> stdout [
	^ self stdioHandle: #stdout
]

{ #category : #all }
File class >> stderr [
	^ self stdioHandle: #stderr
]

{ #category : #all }
File class >> stdioHandle: aSymbol [
	| handleIndex id |
	handleIndex := #(#stdin #stdout #stderr) indexOf: aSymbol ifAbsent: [ self error: 'Unknown stdio handle ', aSymbol ].
	id := self primStdioHandles at: handleIndex.
	id
		ifNotNil: [
			^ self basicNew
				initializeWithId: id ;
				yourself ]
		ifNil: [ self error: 'The stdio handle ', aSymbol, ' is not present' ]
]

{ #category : #all }
File class >> primAtEnd: id [
	"Answer true if the file position is at the end of the file."

	<primitive: 'primitiveFileAtEnd' module: 'FilePlugin'>
	self primitiveFailed
]

{ #category : #all }
File class >> primClose: id [
	"Close this file."

	<primitive: 'primitiveFileClose' module: 'FilePlugin'>
]

{ #category : #all }
File class >> primFlush: id [
	"On Unix, the FilePlugin uses stdio FILE* structs which maintain their
	own internal buffer to minimize write() syscalls. This flushes that buffer.
	On Windows this and primSync: do the same thing."

	<primitive: 'primitiveFileFlush' module: 'FilePlugin'>
	
	"We can't ignore fflush() failing, because it can fail for any of the
	reasons write() can."
	self primitiveFailed
]

{ #category : #all }
File class >> primOpen: fileName writable: writableFlag [
	"Open a file of the given name, and return the file ID obtained.
	If writableFlag is true, then
		if there is none with this name, then create one
		else prepare to overwrite the existing from the beginning
	otherwise
		if the file exists, open it read-only
		else return nil"

	<primitive: 'primitiveFileOpen' module: 'FilePlugin'>
	^ nil
]

{ #category : #all }
File class >> primGetPosition: id [
	"Get this files current position."

	<primitive: 'primitiveFileGetPosition' module: 'FilePlugin'>
	self primitiveFailed
]

{ #category : #all }
File class >> primSetPosition: id to: anInteger [
	"Set this file to the given position."

	<primitive: 'primitiveFileSetPosition' module: 'FilePlugin'>
	self primitiveFailed
]

{ #category : #all }
File class >> primRead: id into: byteArray startingAt: startIndex count: count [
	"Read up to count bytes of data from this file into the given string or byte array starting at the given index. Answer the number of bytes actually read."

	<primitive: 'primitiveFileRead' module: 'FilePlugin'>
	self primitiveFailed
]

{ #category : #all }
File class >> primSize: id [
	"Answer the size of this file."

	<primitive: 'primitiveFileSize' module: 'FilePlugin'>
	self primitiveFailed
]

{ #category : #all }
File class >> primSizeOrNil: id [
	"Answer the size of this file."

	<primitive: 'primitiveFileSize' module: 'FilePlugin'>
	^ nil
]

{ #category : #all }
File class >> primStdioHandles [
	<primitive: 'primitiveFileStdioHandles' module: 'FilePlugin' error: ec>
	self primitiveFailed
]

{ #category : #all }
File class >> primSync: id [
	"On Unix, this syncs any written or flushed data still in the kernel file
	system buffers to disk. On Windows this and primFlush: do the same thing"

	<primitive: 'primitiveFileSync' module: 'FilePlugin'>

	"fsync() failing cannot be ignored"
	self primitiveFailed
]

{ #category : #all }
File class >> primTruncate: id to: anInteger [
	"Truncate this file to the given position."

	<primitive: 'primitiveFileTruncate' module: 'FilePlugin'>
	self primitiveFailed
]

{ #category : #all }
File class >> primWrite: id from: stringOrByteArray startingAt: startIndex count: count [
	"Write count bytes onto this file from the given string or byte array starting at the given index. 	Answer the number of bytes written."

	<primitive: 'primitiveFileWrite' module: 'FilePlugin'>
	self primitiveFailed 
]

{ #category : #all }
File >> initializeWithId: anInteger [
	id := anInteger
]

{ #category : #all }
File >> << anObject [
	| buffer |
	buffer := anObject class = ByteArray
		ifTrue: [ anObject ]
		ifFalse: [ anObject asString ].
	self nextPutAll: buffer
]

{ #category : #all }
File >> atEnd [
	^ self class primAtEnd: id
]

{ #category : #all }
File >> close [
	self class primClose: id
]

{ #category : #all }
File >> cr [
	self nextPut: Character cr
]

{ #category : #all }
File >> closed [
	^ self sizeOrNil isNil
]

{ #category : #all }
File >> flush [
	self class primFlush: id
]

{ #category : #all }
File >> lf [
	self nextPut: Character lf
]

{ #category : #all }
File >> next [
	| buffer |
	buffer := self next: 1.
	^ buffer
		ifNotEmpty: [ buffer first ]
		ifEmpty: [ nil ]
]

{ #category : #all }
File >> next: count [
	"Answer a String containing the next count bytes of the file. If there are not count bytes left in the file, answer a String with as many bytes as available."

	| buffer n |
	buffer := ByteString new: count.
	n := self
		primRead: id
		into: buffer
		startingAt: 1
		count: count.
	^ n < count
		ifTrue: [ buffer copyFrom: 1 to: n ]
		ifFalse: [ buffer ]
]

{ #category : #all }
File >> nextPut: aCharacterOrByte [
	self nextPutAll: (aCharacterOrByte isInteger
		ifTrue: [ ByteArray with: aCharacterOrByte ]
		ifFalse: [ ByteString with: aCharacterOrByte ])
]

{ #category : #all }
File >> nextPutAll: stringOrByteArray [
	"Write the contents of the given bytes or words object to this file."

	^ self class
		primWrite: id
		from: stringOrByteArray
		startingAt: 1
		count: stringOrByteArray basicSize
]

{ #category : #all }
File >> position [
	^ self class primGetPosition: id
]

{ #category : #all }
File >> position: anInteger [
	self class primSetPosition: id to: anInteger
]

{ #category : #all }
File >> readInto: byteArray startingAt: startIndex count: count [
	"Read bytes and answer number of bytes read"
	^ self class primRead: id into: byteArray startingAt: startIndex count: count
]

{ #category : #all }
File >> size [
	^ self class primSize: id
]

{ #category : #all }
File >> sizeOrNil [
	^ id ifNotNil: [ self class primSizeOrNil: id ]
]

{ #category : #all }
File >> sync [
	self class primSync: id
]

{ #category : #all }
File >> truncateTo: anInteger [
	self class primTruncate: id to: anInteger
]

{ #category : #all }
File >> writeFrom: stringOrByteArray startingAt: startIndex count: count [
	"Write bytes and answer number of bytes written"
	^ self class primWrite: id from: stringOrByteArray startingAt: startIndex count: count
]
