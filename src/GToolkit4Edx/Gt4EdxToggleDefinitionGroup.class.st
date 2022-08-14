Class {
	#name : #Gt4EdxToggleDefinitionGroup,
	#superclass : #MooseGroup,
	#category : #'GToolkit4Edx-Model'
}

{ #category : #accessing }
Gt4EdxToggleDefinitionGroup >> annotation [
	
	<package: #FAMIX>
]

{ #category : #accessing }
Gt4EdxToggleDefinitionGroup >> gtModuleDependenciesFor: aView [
	<gtView>
	^ aView mondrian 
		title: 'Module depedendencies';
		priority: 1;
		painting: [ :m | self paintModuleDependenciesWith: m ]
]

{ #category : #accessing }
Gt4EdxToggleDefinitionGroup >> paintModuleDependenciesWith: m [
	| dependencies |
	dependencies := Dictionary new.
	(self reject: [ :each | each containerFiles size > 1 ])
		do: [ :toggle | 
			toggle uses
				do: [ :use | 
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
		with: ((dependencies keys collect: #key) , (dependencies keys collect: #value)) asSet.
	m edges
		stencil: [ :assoc | 
			BlParabollaArcElement new
				when: BlClickEvent
					do: [ :e | 
						e target phlow spawnObject: assoc value asMooseGroup.
						e consumed: true ];
				curvatureFraction: 0.3;
				border: (BlBorder paint: Color red width: assoc value size / 40);
				toHead: (BlArrowheadSimpleArrow new background: Color red) ];
		connect: (dependencies associations
					reject: [ :assoc | assoc key key = assoc key value ])
			from: [ :assoc | assoc key key ]
			to: [ :assoc | assoc key value ].
	m layout circle radius: 100.
	^ m
]
