Class {
	#name : 'Gt4EdxGlobals',
	#superclass : 'Object',
	#classInstVars : [
		'rootDirectory'
	],
	#category : 'GToolkit4Edx-Model'
}

{ #category : 'accessing' }
Gt4EdxGlobals class >> rootDirectory [
	^ rootDirectory
]

{ #category : 'accessing' }
Gt4EdxGlobals class >> rootDirectory: aString [ 
	rootDirectory := aString asFileReference
]
