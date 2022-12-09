Extension { #name : #RBMethodNode }

{ #category : #'*TinyBootstrap' }
RBMethodNode >> primitive [

	"Answer the primitive number of the receiver.

	Implementation:
	For tiny image the original implementation is changed, since it did not
	answer the correct primitive number (117) for named primitives."

	^ self primitiveFromPragma num

	"Original implementation below:"
	"^ (self pragmas detect: [ :each | each isPrimitive ])
			arguments first value"
]
