Class {
	#name : #PBImageBuilderTinyImage64bit,
	#superclass : #PBImageBuilderTinyImage32bit,
	#category : #'TinyBootstrap-Core'
}

{ #category : #initialization }
PBImageBuilderTinyImage64bit >> initializeBackend [

	espellBackend := EPSimulatorBackend for64Bit forBootstrap
]
