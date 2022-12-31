Class {
	#name : #ProcessorScheduler,
	#superclass : #Object,
	#instVars : [
		'suspendedProcessLists',
		'activeProcess'
	],
	#category : #'Kernel-Processes'
}

{ #category : #all }
ProcessorScheduler class >> new [
	"The VM depends on a unique scheduler."

	self cannotInstantiate
]

{ #category : #all }
ProcessorScheduler >> activeProcess [
	"Answer the currently running Process."

	^ activeProcess
]

{ #category : #all }
ProcessorScheduler >> highestPriority [
	"Answer the number of priority levels currently available for use."

	^ suspendedProcessLists size
]

{ #category : #all }
ProcessorScheduler >> highIOPriority [
	^ self highestPriority - 1
]

{ #category : #all }
ProcessorScheduler >> initProcessLists [
	"Create process lists for prioriy levels 1 through 5."

	suspendedProcessLists := (1 to: 5)
		collect: [ :i | ProcessList new ]
]

{ #category : #all }
ProcessorScheduler >> remove: aProcess ifAbsent: aBlock [
	"Remove the given process from the list on which it is waiting. If the process is not on the queue for it's priority, evaluate the given block. Always answer the process."

	(suspendedProcessLists at: aProcess priority)
		remove: aProcess
		ifAbsent: aBlock.
	^ aProcess
]
