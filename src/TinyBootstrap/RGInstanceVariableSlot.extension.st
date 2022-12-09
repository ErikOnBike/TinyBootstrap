Extension { #name : #RGInstanceVariableSlot }

{ #category : #'*TinyBootstrap' }
RGInstanceVariableSlot >> readWith: anInterpreter inNode: aVariableNode [    
	^ anInterpreter readInstVarAt: self index named: name
]
