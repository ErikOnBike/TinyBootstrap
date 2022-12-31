Class {
	#name : #Semaphore,
	#superclass : #LinkedList,
	#instVars : [
		'excessSignals'
	],
	#category : #'Kernel-Processes'
}

{ #category : #all }
Semaphore class >> forMutualExclusion [
	"Answer an instance of me that contains a single signal. This new 
	instance can now be used for mutual exclusion (see the critical: message 
	to Semaphore)."

	^self new signal
]

{ #category : #all }
Semaphore >> = anObject [
	^ self == anObject
]

{ #category : #all }
Semaphore >> critical: mutuallyExcludedBlock [
	"Evaluate mutuallyExcludedBlock only if the receiver is not currently in
	the process of running the critical: message. If the receiver is, evaluate
	mutuallyExcludedBlock after the other critical: message is finished."
	
	"We need to catch eventual interruptions very carefully.
	The naive approach of just doing, e.g.,:
			self wait.
			aBlock ensure: [self signal].
	will fail if the active process gets terminated while in the wait.
	However, the equally naive:
			[self wait.
			aBlock value] ensure: [self signal].
	will fail too, since the active process may get interrupted while
	entering the ensured block and leave the semaphore signaled twice.
	To avoid both problems we make use of the fact that interrupts only
	occur on sends (or backward jumps) and use an assignment (bytecode)
	right before we go into the wait primitive (which is not a real send and
	therefore not interruptable either)."
	
	| blockValue caught |
	caught := false.
	[
		caught := true.
		self wait.
		blockValue := mutuallyExcludedBlock value
	] ensure: [caught ifTrue: [self signal]].
	^blockValue
]

{ #category : #all }
Semaphore >> hash [
	^ self identityHash
]

{ #category : #all }
Semaphore >> initialize [
	"Consume any excess signals the receiver may have accumulated."

	excessSignals := 0
]

{ #category : #all }
Semaphore >> signal [
	"Primitive. Increment my signal count. If one or more processes are waiting on me, allow the first one to proceed. If no process is waiting, just remember the excess signal. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 85>
	self primitiveFailed
]

{ #category : #all }
Semaphore >> wait [
	"Primitive. This semaphore must have a signal before the caller's process can proceed. If I have no signals, the process is suspended this semaphore is signalled. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 86>
	self primitiveFailed
]

{ #category : #all }
Semaphore >> consumeAllSignals [
	"Consume any excess signals the receiver may have accumulated."

	excessSignals := 0
]
