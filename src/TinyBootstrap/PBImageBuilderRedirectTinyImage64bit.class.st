"
BE AWARE:
I am a redirector for the PBImageBuilderTinyImage64bit.
My sole purpose is to make sure the default bootstrap process works
without too many changes. The PBBootstrap class requests an ImageBuilder
instance from the PBImageBuilderSpur50 class which unfortunately only
checks for direct subclasses for a matching variant. I therefore am
such a direct subclass, but when asked for an instance (using #new) I
answer the actual PBImageBuilderTinyImage64bit instance.

See PBImageBuilderSpur50 class >> #forArchitecture:

"
Class {
	#name : #PBImageBuilderRedirectTinyImage64bit,
	#superclass : #PBImageBuilderSpur50,
	#category : #'TinyBootstrap-Core'
}

{ #category : #'instance creation' }
PBImageBuilderRedirectTinyImage64bit class >> new [

	"Answer an actual ImageBuilder for tiny images using 64 bits.

	See the class comment."

	^ PBImageBuilderTinyImage64bit new
]
