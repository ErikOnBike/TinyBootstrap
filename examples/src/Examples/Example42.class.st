Class {
	#name : #Example42,
	#superclass : #Object,
	#category : #Examples
}

{ #category : #all }
Example42 class >> doIt [

	File stdout
		<< Character lf ;
		<< 'Answer: ' ;
		<< (6 * 7) ;
		<< Character lf.

	Smalltalk quit
]
