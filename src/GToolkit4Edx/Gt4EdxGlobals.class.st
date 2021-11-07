Class {
	#name : #Gt4EdxGlobals,
	#superclass : #Object,
	#classInstVars : [
		'rootDirectory',
		'model'
	],
	#category : #'GToolkit4Edx-Model'
}

{ #category : #accessing }
Gt4EdxGlobals class >> rootDirectory [
	^ rootDirectory
]

{ #category : #accessing }
Gt4EdxGlobals class >> rootDirectory: aString [ 
	rootDirectory := aString asFileReference
]

{ #category : #accessing }
Gt4EdxGlobals class >> toggleModel [
	^ model ifNil: [ 
		  | importer asts |
		  importer := Gt4EdxImporter new.
		  asts := importer parseDirectory: self rootDirectory.
		  model := importer
			           importASTs: asts;
			           model ]
]
