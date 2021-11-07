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
Gt4EdxGlobals class >> paintToggleDependenciesWith: m [

	| dependencies |
	dependencies := Dictionary new.
	(Gt4EdxGlobals toggleModel allEdxToggles reject: [ :each | 
		 each containerFiles size > 1 ]) do: [ :toggle | 
		toggle uses do: [ :use | 
			| assoc |
			assoc := use containerFiles anyOne edxTopComponent
			         -> toggle containerFiles anyOne edxTopComponent.
			dependencies at: assoc ifAbsentPut: [ OrderedCollection new ].
			(dependencies at: assoc) add: use ] ].
	m nodes
		stencil: [ :each | 
			BrLabel new
				text: each name;
				aptitude: BrGlamorousLabelAptitude ];
		with: ((dependencies keys collect: #key)
			 , (dependencies keys collect: #value)) asSet.
	m edges
		stencil: [ :assoc | 
			BlParabollaArcElement new
				when: BlClickEvent do: [ :e | 
					e target phlow spawnObject: assoc value asMooseGroup.
					e consumed: true ];
				curvatureFraction: 0.3;
				border: (BlBorder paint: Color red width: assoc value size / 40);
				toHead: (BlArrowheadSimpleArrow new background: Color red) ];
		connect: (dependencies associations reject: [ :assoc | 
				 assoc key key = assoc key value ])
		from: [ :assoc | assoc key key ] to: [ :assoc | assoc key value ].
	m layout circle radius: 100.
	^ m
]

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
