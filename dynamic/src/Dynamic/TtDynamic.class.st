Class {
	#name : #TtDynamic,
	#superclass : #Object,
	#classVars : [
		'EndOption'
	],
	#category : #Dynamic
}

{ #category : #all }
TtDynamic class >> one [
	self crTrace: 'one executed'
]

{ #category : #all }
TtDynamic class >> two [
	self crTrace: 'two executed'
]

{ #category : #all }
TtDynamic class >> doIt [

	| index commandToSelectorMapping option class selector |

	"Perform all commands sequentially (based on order on command line"
	index := 2.
	commandToSelectorMapping := self commandToSelectorMapping.
	[ (option := Smalltalk getSystemAttribute: index) isNotNil ] whileTrue: [
		(option beginsWith: '--')
			ifTrue: [

				| command commandSelector argumentCount arguments |

				"Map command onto selector"
				command := option allButFirst: 2.
				(commandSelector := commandToSelectorMapping at: command ifAbsent: [ nil ])
					ifNil: [
						self crError: 'Unknown command: ', command.
						Smalltalk quit ].

				"Read argument for command (based on number of arguments the selector requires)"
				argumentCount := commandSelector occurrencesOf: $:.
				arguments := Array new: argumentCount.
				1 to: argumentCount do: [ :argumentIndex |
					(arguments at: argumentIndex put: (Smalltalk getSystemAttribute: index + argumentIndex))
						ifNil: [
							self crError: 'Not enough arguments specified for command: ', command, ' (', argumentCount printString, ' expected, but ', (argumentIndex - 1) printString, ' received)'.
							Smalltalk quit ] ].

				"Execute the command"
				self perform: commandSelector asSymbol withArguments: arguments.

				"Continu to next command/argument (+ 1 for command itself)"
				index := index + argumentCount + 1 ]
			ifFalse: [

				"Validate a class/selector combi is not already specified"
				class
					ifNotNil: [
						self crError: 'A class and selector are already specified'.
						Smalltalk quit ].

				"Command contains class name"
				(class := Smalltalk classNamed: option asSymbol)
					ifNil: [
						self crError: 'Unknown class specified: ', option.
						Smalltalk quit ].

				"Read selector"
				index := index + 1.
				selector := (Smalltalk getSystemAttribute: index)
					ifNotNil: [ :selectorString | selectorString asSymbol ]
					ifNil: [
						self crError: 'No selector specified for class: ', option.
						Smalltalk quit ].

				"Continu to next command/argument"
				index := index + 1 ] ].

	"Perform the specified class/selector combi (if specified and not fusing)"
	(EndOption ~~ #fuse and: [ class isNotNil ])
		ifTrue: [ self performOperation: selector on: class ].

	"End application based on user specified option."
	"Simply quit. Next run will execute #doIt again."
	(EndOption isNil or: [ EndOption == #quit ])
		ifTrue: [ Smalltalk quit ].

	"Save snapshot and make sure (explicitly) #doIt is executed again on next run."
	EndOption == #save
		ifTrue: [
			EndOption := nil.	"Reset for next run"
			Smalltalk
				garbageCollect ;
				snapshotAndQuit.
			^ self doIt ].

	"Fuse application by removing this class and helper classes.
	Assume a valid startup is provided by the user."

	"Validate a new startup command is given"
	(class isNil or: [ selector isNil ])
		ifTrue: [
			self crError: 'Fusing not possible without startup method specified (going to quit without saving)'.
			Smalltalk quit ].

	"Remove classes"
	#(#TtDynamic #TtObjectDecoder)
		do: [ :each | self uninstallClass: each ].

	"Set startup parameters"
	Smalltalk at: #ttStartupClass put: class.
	Smalltalk at: #ttStartupSelector put: selector.

	"Start new process"
	[
		Smalltalk
			garbageCollect ;
			snapshotAndQuit.

		"Run the following code on next run"
		(Smalltalk classNamed: #ttStartupClass) perform: (Smalltalk at: #ttStartupSelector).

		"If the code above does not stop, quit here"
		Smalltalk quit
	] fork.

	"Terminate current (allowing actual GC of myself)"
	Processor activeProcess terminate
]

{ #category : #all }
TtDynamic class >> commandToSelectorMapping [
	^ Dictionary new
		at: #help put: #showHelp ;
		at: #install put: #installCodeFrom: ;
		at: #uninstall put: #uninstallClass: ;
		at: #quit put: #endOptionQuit ;
		at: #save put: #endOptionSave ;
		at: #fuse put: #endOptionFuse ;
		yourself
]

{ #category : #all }
TtDynamic class >> performOperation: aSymbol on: aClass [
	[ aClass perform: aSymbol ] on: Exception do: [ :ex |
		self crError: 'Failed to perform requested operation: ', aClass name, ' ', aSymbol asString, String lf, ex printString.
		Smalltalk quit ]
]

{ #category : #all }
TtDynamic class >> showHelp [
	| vm image index |

	vm := (Smalltalk getSystemAttribute: 0) ifNil: [ 'pharo' ].
	image := (Smalltalk getSystemAttribute: 1) ifNil: [ 'your.image' ].

	"Remove path from vm and image (simplistic approach)"
	index := vm findLast: [ :each | each = $/ or: [ each = $\ ] ].
	index > 0
		ifTrue: [ vm := vm allButFirst: index ].
	index := image findLast: [ :each | each = $/ or: [ each = $\ ] ].
	index > 0
		ifTrue: [ image := image allButFirst: index ].

	self
		crTrace: 'Usage: ', vm, ' ', image, ' [--install <filename>]* [--uninstall <classname>]* [class selector] [--quit|--save|--fuse]' ;
		crTrace: '' ;
		crTrace: 'The options "install" and "uninstall" can be repeated.' ;
		crTrace: 'Choose one of the options "quit", "save" or "fuse" (if none specified, "quit" is used).' ;
		crTrace: 'A single class name and selector name can be specified which is executed after' ;
		crTrace: 'installing/uninstalling code (when not fusing).' ;
		crTrace: 'When "fuse" is specified the code which processes the install/uninstall options is removed,' ;
		crTrace: 'the image is saved and on next execution the specified selector is sent to the specified class.' ;
		crTrace: 'Fusing removes the dynamic character of the image and fixates it to the specified startup class/method.'
]

{ #category : #all }
TtDynamic class >> installCodeFrom: aFileName [
	| bytes |

	"Read encoded classes and methods"
	[
		| file |

		file := File open: aFileName writable: false.
		bytes := ByteArray new: file size.
		file readInto: bytes startingAt: 1 count: bytes size
	] on: Exception do: [ :ex |
		self crError: 'Can''t read the content of the specified file: ', aFileName, String lf, ex printString ].

	"Decode all classes/compiled methods in the file"
	[
		| decoder |

		decoder := TtObjectDecoder on: bytes.
		[ decoder hasMoreData ] whileTrue: [
			| methodOrClass |

			methodOrClass := decoder decodeNext.
			methodOrClass isClass
				ifFalse: [
					"Install method (classes are installed by default)"
					methodOrClass install ] ]
	] on: Exception do: [ :ex |
		self crError: 'Can''t decode file: ', aFileName, String lf, ex printString ]
]

{ #category : #all }
TtDynamic class >> uninstallClass: aString [
	| className |
	className := aString asSymbol.
	(Smalltalk classNamed: className)
		ifNil: [ self crWarn: 'Uninstalling unknown class named: ', className ].

	Smalltalk globals removeKey: className ifAbsent: [ "ignore" ]
]

{ #category : #all }
TtDynamic class >> endOptionQuit [
	self endOption: #quit
]

{ #category : #all }
TtDynamic class >> endOptionSave [
	self endOption: #save
]

{ #category : #all }
TtDynamic class >> endOptionFuse [
	self endOption: #fuse
]

{ #category : #all }
TtDynamic class >> endOption: aSymbol [
	EndOption ifNotNil: [ self crWarn: 'Multiple options given how to end application. Using latest: ', aSymbol ].
	EndOption := aSymbol
]
