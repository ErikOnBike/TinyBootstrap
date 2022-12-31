Class {
	#name : #Mutex,
	#superclass : #Object,
	#instVars : [
		'semaphore',
		'owner'
	],
	#category : #'Kernel-Processes'
}

{ #category : #all }
Mutex >> critical: aBlock [
	"Evaluate aBlock protected by the receiver."
	| activeProcess |

	activeProcess := Processor activeProcess.
	activeProcess == owner ifTrue:[ ^ aBlock value ].
	^ semaphore critical: [
		owner := activeProcess.
		aBlock ensure:[ owner := nil ] ]
]

{ #category : #all }
Mutex >> initialize [
	super initialize.
	semaphore := Semaphore forMutualExclusion.
]
