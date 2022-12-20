"
I am an image builder for tiny images. These images are Spur based.

Implementation:
My name is chosen explicitly so I can be used with the TinyBootstrap
class which knows how to use my name.

"
Class {
	#name : #PBImageBuilderTinyImage32bit,
	#superclass : #PBImageBuilderSpur5032bit,
	#instVars : [
		'startUp'
	],
	#category : #'TinyBootstrap-Core'
}

{ #category : #helpers }
PBImageBuilderTinyImage32bit >> checkpoint: aString [

	self crTrace: aString
]

{ #category : #running }
PBImageBuilderTinyImage32bit >> createClasses [

	"Create all classes.

	Implementation:
	Special variant for tiny image in which the order of class creation
	is important (ES: Have been unable to find exact reason why default
	implementation does not work for tiny image. The result of not putting
	in explicit order is that classes which are created before their
	superclass, are not registered correctly with the superclass. There
	does not seem an explicit fix for this in the 'regular' code, but
	setting the order here will prevent such issues for now.).
	This method should be exact copy of superclass' implementation in
	which only required changes are made.
	(The changes are commented with 'TI' - Tiny Image)."

	| definitions total smalltalkInstance |
	definitions := self systemDefinition ask allClassesAndTraits sorted: [ 
		               :a 
		               :b | | aDepth bDepth | (b inheritsFrom: a) or: [ (a inheritsFrom: b) not and: [ (aDepth := a allSuperclasses size) < (bDepth := b allSuperclasses size) or: [ aDepth = bDepth and: [ a name < b name ] ] ] ] ].			"TI: Create classes only when superclass is already known/created, so subclasses are registered correctly"
	total := definitions size.
	definitions withIndexDo: [ :aClassDefinition :index | 
		| time |
		time := [ self createBehaviorFromDefinition: aClassDefinition ]
			        timeToRun.

		PBSubStepFinishedSignal emit:
			(index printPaddedWith: $0 to: 3) , '/' , total asString , ' - '
			, time asString , ': Built behavior ' , aClassDefinition name ].

	smalltalkInstance := bootstrapEnvironment at: #Smalltalk.
	objectSpace interpreter: bootstrapInterpreter.
	objectSpace backend smalltalkInstance: smalltalkInstance.
	objectSpace environment: ((EPSystemDictionary withSystemDictionary:
				  objectSpace backend systemDictionary)
			 objectSpace: objectSpace;
			 yourself).

	self mapCommonClasses.													"TI: Map some common classes to classes within the tiny image"

	PBStepFinishedSignal emit: 'Classes created'.
	self checkpoint: 'created_classes'
]

{ #category : #running }
PBImageBuilderTinyImage32bit >> createInitialObjects [

	"Create initial objects.

	Implementation:
	Special variant for tiny image in which a number of classes is not
	present and therefore creation is not possible.
	This method should be exact copy of superclass' implementation in
	which only required changes are made. Sometimes code is kept although
	no actual behavior is present, like calling 'Object initialize' which
	defaults back to the empty implementation.
	(The changes are commented with 'TI' - Tiny Image)."

	| characterTable |
	"We add the main globals  in the bootstrap environment before a system dictionary exists. These globals are needed to create a system dictionary, and will be used by the AST interpreter"
	PBStepFinishedSignal emit: 'initializing globals'.
	self bootstrapEnvironment at: #Smalltalk put: objectSpace nilObject.
	self bootstrapEnvironment at: #Undeclared put: objectSpace nilObject.

	"We initialize the hash table sizes by hand.
	The AST interpreter is too slow to interpret HashTableSizes>>#initialize"
	"PBSubStepFinishedSignal emit: 'initializing hash table sizes'.

	(self classNamed: #HashTableSizes) mirror
		instanceVariableAtIndex: (self classInstanceVariableIndexAt: 1)
		put: (objectSpace newArrayWithAll:
				 (HashTableSizes sizes collect: [ :each | 
					  objectSpace backend smallIntegerMirrorOn: each ]))."				"TI: Not available"

	PBSubStepFinishedSignal emit: 'preparing class builder'.
	"self bootstrapInterpreter evaluateCode:
		'DangerousClassNotifier disable'."													"TI: Not available"

	self bootstrapInterpreter evaluateCode:
		'Undeclared := Dictionary new.'.
	self bootstrapInterpreter evaluateCode:
		'Smalltalk := SmalltalkImage basicNew.'.
	self bootstrapInterpreter evaluateCode:
		"'Smalltalk instVarAt: 1 put: (SystemDictionary withOrganizer: SystemOrganizer new).'"		"TI: SystemOrganizer is not available"
		'Smalltalk instVarAt: 1 put: (SystemDictionary new)'.
	self bootstrapInterpreter evaluateCode:
		'Smalltalk globals at: #Smalltalk put: Smalltalk.'.
	self bootstrapInterpreter evaluateCode:
		'Smalltalk globals at: #Undeclared put: Undeclared.'.

	"Initialize the globals of the system. Careful: The AST interpreter will not know about these if we do not put them in the bootstrapEnvironment."
	self bootstrapInterpreter evaluateCode:
		'Smalltalk globals at: #Processor put: nil.'.
	"self bootstrapInterpreter evaluateCode:
		'Smalltalk globals at: #Transcript put: nil.'."									"TI: Not available (no use in creating global)"
	"self bootstrapInterpreter evaluateCode:
		'Smalltalk globals at: #SystemOrganisation put: nil.'."							"TI: Not available (no use in creating global)"
	"self bootstrapInterpreter evaluateCode:
		'Smalltalk globals at: #SourceFiles put: nil.'."									"TI: Not available (no use in creating global)"


	PBSubStepFinishedSignal emit: 'class loader now creates class pools'.
	classLoader initializeClassPools.

	PBSubStepFinishedSignal emit: 'Initializing StartUp list'.
	self bootstrapInterpreter evaluateCode: 'SmalltalkImage initialize.'.

	PBSubStepFinishedSignal emit: 'Initializing Character Table'.
	self bootstrapInterpreter evaluateCode: 'Character initialize.'.
	"characterTable := EPInternalCharacterTable new objectSpace:
		                  objectSpace.
	objectSpace backend characterTable:
		((self classNamed: #Character) classPool at: #CharacterTable).
	objectSpace characterTable: characterTable."											"TI: Not available"

	PBSubStepFinishedSignal emit: 'Initializing String AsciiTable'.
	"self bootstrapInterpreter evaluateCode:
		'String classPool at: #AsciiOrder put: ((0 to: 255) as: ByteArray).'."		"TI: Not available"

	PBSubStepFinishedSignal emit: 'Initializing SmallInteger constants'.
	"self bootstrapInterpreter evaluateCode: 'SmallInteger instVarAt: '
		, (self classInstanceVariableIndexAt: 1) asString
		, ' put: -16r40000000.'." "minVal"													"TI: Not available (minVal is hardcoded in Class)"
	"self bootstrapInterpreter evaluateCode: 'SmallInteger instVarAt: '
		, (self classInstanceVariableIndexAt: 2) asString
		, ' put: 16r3FFFFFFF.'." "maxVal"														"TI: Not available (maxVal is hardcoded in Class)"

	PBSubStepFinishedSignal emit: 'Initializing Float constants'.
	self bootstrapInterpreter evaluateCode: 'Float initialize.'.						"TI: Missing in 'regular' bootstrap"
	
	PBSubStepFinishedSignal emit: 'Initializing Date and Time constants'.
	"self bootstrapInterpreter evaluateCode: 'DateAndTime initialize.'.
	self bootstrapInterpreter evaluateCode:
		'ChronologyConstants initialize.'."													"TI: Not available"

	PBSubStepFinishedSignal emit: 'Initializing CompiledMethod constants'.
	self bootstrapInterpreter evaluateCode: 'CompiledMethod initialize.'.

	PBSubStepFinishedSignal emit: 'Initializing object dependent fields'.
	self bootstrapInterpreter evaluateCode: 'Object initialize.'.

	PBSubStepFinishedSignal emit: 'Installing symbol table'.
	"self bootstrapInterpreter evaluateCode: 'Symbol initialize.
	Symbol classPool at: #SymbolTable put: (WeakSet withAll: ByteSymbol allInstances)'.
	objectSpace symbolTable:
		(EPInternalSymbolTable new objectSpace: objectSpace)."							"TI: Not available"


	PBSubStepFinishedSignal emit: 'Bootstrapping class layouts'.
	"bootstrapInterpreter evaluateCode: ('| superLayout |
		superLayout := EmptyLayout instance.
		Class
			instVarAt: 4
			put: (FixedLayout
					extending: superLayout 
					scope: (superLayout slotScope extend: #({1}))
					host: Class).
		
		SmallInteger
			instVarAt: 4
			put: (ImmediateLayout new).' format:
			 { self espellBackend instanceVariableMapping listOfClassSlots })."		"TI: Not available (layouts are not present, old style still in use)"

	PBStepFinishedSignal emit: 'Class builder ready to create classes'.
	classLoader useClassBuilder.

	self checkpoint: 'created_initial_objects'
]

{ #category : #running }
PBImageBuilderTinyImage32bit >> createVMStubs [

	"Create VM stubs.

	Implementation:
	Special variant for tiny image in which a number of classes is not
	present and therefore creation is not possible.
	This method should be exact copy of superclass' implementation in
	which only required changes are made.
	(The changes are commented with 'TI' - Tiny Image)."

	| specialObjectsArray |
	super log: 'creating initial Objects needed by the VM'.

	self createNil.	
	self createFalse.
	self createTrue.

	self allocateFreeLists.	
	self allocateClassTable.
	
	specialObjectsArray := self objectSpace backend 
		createObjectWithFormat: Array format withSize: 60 classIndex: self arrayClassIndex.
	objectSpace specialObjectsArray: specialObjectsArray.
	objectSpace nilObject: objectSpace nilObject.
	objectSpace falseObject: objectSpace falseObject.
	objectSpace trueObject: objectSpace trueObject.
	
	objectSpace nilObject setClass: (self createStubForClassNamed: #UndefinedObject).
	objectSpace falseObject setClass: (self createStubForClassNamed: #False).
	objectSpace trueObject setClass: (self createStubForClassNamed: #True).
	
	
	objectSpace backend smallIntegerClass: (self createStubForClassNamed: #SmallInteger).
	objectSpace backend characterClass: (self createStubForClassNamed: #Character).
	"objectSpace backend byteSymbolClass: (self createStubForClassNamed: #ByteSymbol)."				"TI: Replace by #Symbol below"
	objectSpace backend byteSymbolClass: (self createStubForClassNamed: #Symbol).
	objectSpace backend byteStringClass: (self createStubForClassNamed: #ByteString).
	objectSpace backend byteArrayClass: (self createStubForClassNamed: #ByteArray).
	objectSpace backend associationClass: (self createStubForClassNamed: #Association).
	objectSpace backend arrayClass: (self createStubForClassNamed: #Array).
	"objectSpace backend symbolTableClass: (self createStubForClassNamed: #Symbol)."				"TI: Already created, therefore use existing"
	objectSpace backend symbolTableClass: objectSpace backend byteSymbolClass.
	objectSpace backend largeNegativeIntegerClass: (self createStubForClassNamed: #LargeNegativeInteger).
	objectSpace backend largePositiveIntegerClass: (self createStubForClassNamed: #LargePositiveInteger).
	objectSpace backend methodClass: (self createStubForClassNamed: #CompiledMethod).
	objectSpace backend floatClass: (self createStubForClassNamed: #Float).							"TI: Non boxed Float(32)"
	objectSpace backend smallFloatClass: objectSpace backend floatClass.								"TI: For 64 bits"
	objectSpace backend contextClass: (self createStubForClassNamed: #Context).
	objectSpace backend processClass: (self createStubForClassNamed: #Process).
	objectSpace backend blockClass: (self createStubForClassNamed: #BlockClosure).
	objectSpace backend fullBlockClass: (self createStubForClassNamed: #FullBlockClosure).
	objectSpace backend messageClass: (self createStubForClassNamed: #Message).
	objectSpace backend semaphoreClass: (self createStubForClassNamed: #Semaphore).
	
	objectSpace backend compiledBlockClass: (self createStubForClassNamed: #CompiledBlock ).

	"Point is required in the special objects array because it is used to instantiate point objects faster.
	If we do not put it here, the VM will crash.
	Lots of tests in kernel use it."
	objectSpace backend pointClass: (self createStubForClassNamed: #Point).
	
	objectSpace backend processorAssociation: (self classNamed: #Association) mirror basicNew.
	objectSpace backend processorAssociation
		instanceVariableAtIndex: 2 put: (self createStubForClassNamed: #ProcessorScheduler) basicNew.
	
	objectSpace backend specialSelectors: ((self classNamed: #Array) mirror basicNew: 64)
]

{ #category : #initialization }
PBImageBuilderTinyImage32bit >> initializeImage [

	"Initialize the bootstrap image.

	Implementation:
	Special variant for tiny image in which a number of classes is not
	present and therefore execution is different.
	This method should be exact copy of superclass' implementation in
	which only required changes are made.
	(The changes are commented with 'TI' - Tiny Image)."

	| process |
	self flag: 'should migrate this method'.
	self checkpoint: 'image_initialization'.

	self initializeSpecialObjectArray.

"	self bootstrapInterpreter evaluateCode: '
	Smalltalk at: #Processor put: (ProcessorScheduler basicNew).
	(Smalltalk at: #Processor) instVarAt: 1 put: ((1 to: 80) collect: [ :i | ProcessList new ])'.
"																							"TI: ProcessScheduler can create its own process list"
	self bootstrapInterpreter evaluateCode: '
	Smalltalk at: #Processor put: (ProcessorScheduler basicNew
		initProcessLists ;
		yourself)'.

	"Initialize the processor association for the special objects array.
	Enchancement possible: This should be automatically managed by the createVMStubs method"
	objectSpace backend processorAssociation:
		(self bootstrapInterpreter evaluateCode:
			 'Smalltalk globals associationAt: #Processor.').

"	process := objectSpace
		           createProcessWithPriority: 40
		           doing: ('PharoBootstrapInitialization 
			initializeImageOfType: ''Pharo'' 
			major: {major} 
			minor: {minor} 
			patch: {patch}
			suffix: ''{suffix}'' 
			build: {build} 
			commitHash: ''{hash}''.' format: { 
					            ('major' -> versionInfo major).
					            ('minor' -> versionInfo minor).
					            ('patch' -> versionInfo patch).
					            ('suffix' -> (versionInfo suffix ifNil: [ '' ])).
					            ('build' -> versionInfo buildNumber).
					            ('hash' -> versionInfo commitHash) } asDictionary).
"																							"TI: Class PharoBootstrapInitialization not present"
	process := objectSpace createProcessWithPriority: 3 doing: (startUp ifNil: [ 'Smalltalk startUp' ]) withTemps: #().
	objectSpace installAsActiveProcess: process.

	self followForwardingPointers.

	espellBackend simulator stackPages pages do: [ :page | 
		espellBackend simulator stackPages freeStackPage: page ].
	espellBackend simulator freeUntracedStackPages.
	[ 
	[ espellBackend objectMemory flushNewSpace ]
		on: Halt
		do: [ :ex | "suppress halts from the usual suspects (development time halts)"
			(#( #fullGC #compactImage #doScavenge: ) includes:
				 ex signalerContext sender selector)
				ifTrue: [ ex resume ]
				ifFalse: [ ex pass ] ] ]
		on: AssertionFailure
		do: [ :e | 
			(e signalerContext sender method selector == #assert: and: [ 
				 e signalerContext sender sender method selector = #mapStackPages ])
				ifTrue: [ e resume ]
				ifFalse: [ e pass ] ].

	self freeForwarders.
	self compactImage.
	self reportSizes.

	self
		writeSnapshot: imageFileReference fullName
		ofTransformedImage: espellBackend simulator objectMemory
		headerFlags: 0
		screenSize: 0.
	PBStepFinishedSignal emit: 'Installed extension methods'
]

{ #category : #initialization }
PBImageBuilderTinyImage32bit >> instantiateClassLoader [

	"Override the class loader"

	classLoader := PBSpurTinyClassLoader new
]

{ #category : #running }
PBImageBuilderTinyImage32bit >> mapCommonClasses [

	"Map some common classes to basic classes within the tiny image"

	self bootstrapInterpreter evaluateCode:
		'Smalltalk at: #GlobalVariable put: Association.
		Smalltalk at: #ClassVariable put: Association.'
]

{ #category : #accessing }
PBImageBuilderTinyImage32bit >> startUp: aString [

	"Set the String which contains the start up code"

	startUp := aString
]
