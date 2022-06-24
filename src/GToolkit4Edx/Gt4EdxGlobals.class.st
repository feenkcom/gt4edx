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
	"this is the root directory for the whole project"
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

{ #category : #accessing }
Gt4EdxGlobals class >> treemapOfComponents [
	^ GtNestedRectangleTreeMap new
	tree: Gt4EdxGlobals rootDirectory;
	deep: #directories;
	leaves: [ :anItem | anItem files select: [:each | each extension = 'py']];
	containerElement: [ :anElement :aNodeContext | 
		| label scaledLabel |
		aNodeContext level = 2 ifTrue: [
			label := BlTextElement new 
				text: (aNodeContext model basename asRopedText
							glamorousRegularFont;
							bold;
							foreground: (Color black alpha: 0.6)).
			scaledLabel := label asScalableElement 
				zIndex: 10; 
				constraintsDo: [:c | 
					c horizontal matchParent. 
					c vertical matchParent. 
					c ignoreByLayout.
					c ignored horizontal weight: 0.2.
					c ignored horizontal alignCenter].
			anElement addChild: scaledLabel].
		anElement border: (BlBorder 
			paint: (Color black alpha: 0.5 / aNodeContext level) 
			width: 2).
		anElement padding: (BlInsets all: 2) ];
	leafElement: [ :anElement :aLeafContext | anElement background: Color white ] 
]

{ #category : #accessing }
Gt4EdxGlobals class >> treemapOfComponentsWithSelectedToggleUsers [
	| toggleUsers |
	toggleUsers := Gt4EdxGlobals toggleModel allEdxToggles flatCollectAsSet: [:toggle | toggle uses collect: [:u | u sourceAnchor fileReference ]].
	^ GtNestedRectangleTreeMap new
	tree: Gt4EdxGlobals rootDirectory;
	deep: #directories;
	leaves: [ :anItem | anItem files select: [:each | each extension = 'py']];
	containerElement: [ :anElement :aNodeContext | 
		| label scaledLabel |
		aNodeContext level = 2 ifTrue: [
			label := BlTextElement new 
				text: (aNodeContext model basename asRopedText
							glamorousRegularFont;
							bold;
							foreground: (Color black alpha: 0.6)).
			scaledLabel := label asScalableElement 
				zIndex: 10; 
				constraintsDo: [:c | 
					c horizontal matchParent. 
					c vertical matchParent. 
					c ignoreByLayout.
					c ignored horizontal weight: 0.2.
					c ignored horizontal alignCenter].
			anElement addChild: scaledLabel].
		anElement border: (BlBorder 
			paint: (Color black alpha: 0.5 / aNodeContext level) 
			width: 2).
		anElement padding: (BlInsets all: 2) ];
	leafElement: [ :anElement :aLeafContext | 
		(toggleUsers includes: aLeafContext model) 
			ifTrue: [ anElement background: Color red ] 
			ifFalse: [
				anElement background: Color white ] ]
]
