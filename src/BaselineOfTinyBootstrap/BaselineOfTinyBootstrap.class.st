Class {
	#name : #BaselineOfTinyBootstrap,
	#superclass : #BaselineOf,
	#category : #BaselineOfTinyBootstrap
}

{ #category : #baselines }
BaselineOfTinyBootstrap >> baseline: spec [

	<baseline>

	spec for: #common do: [

		"Packages"
		spec
			package: 'TinyBootstrap' ;
			package: 'TinyBootstrap-Development'.

		"Groups"
		spec
			group: 'default' with: #( 'Development' ) ;

			group: 'Core' with: #( 'TinyBootstrap' ) ;
			group: 'Development' with: #( 'Core' 'TinyBootstrap-Development' ).
	]
]
