Class {
	#name : #Gt4EdxImporter,
	#superclass : #Object,
	#instVars : [
		'model',
		'currentFile',
		'files',
		'folders',
		'toggles',
		'stringSearches',
		'variableSearches'
	],
	#category : #'GToolkit4Edx-Importer'
}

{ #category : #importing }
Gt4EdxImporter >> addSourceFor: aNode to: anEntity [
	| anchor |
	anchor := self sourceAnchorFor: aNode.
	anEntity sourceAnchor isNil
		ifTrue: [ ^ anEntity sourceAnchor: anchor ].
	(anEntity sourceAnchor isKindOf: FAMIXMultipleFileAnchor)
		ifFalse: [ anEntity
				sourceAnchor:
					(FAMIXMultipleFileAnchor new
						mooseModel: model;
						addSourceAnchor: anEntity sourceAnchor;
						yourself) ].
	anEntity sourceAnchor addSourceAnchor: (self sourceAnchorFor: aNode)
]

{ #category : #importing }
Gt4EdxImporter >> argumentValue: node [
	^ (node isKindOf: PyArgumentNode) ifTrue: [ node value ] ifFalse: [ node ]
]

{ #category : #accessing }
Gt4EdxImporter >> baseDirectory [
	^ model rootFolder
]

{ #category : #accessing }
Gt4EdxImporter >> baseDirectory: aFileReference [
	model rootFolder: aFileReference asFileReference
]

{ #category : #importing }
Gt4EdxImporter >> createToggle: aNode named: aString [
	| name toggle |
	(aNode parent isKindOf: PyFunctionCallExpressionNode) ifFalse: [ ^ false ].
	(aNode attributeNamed: #toggle ifAbsent: [  ]) notNil ifTrue: [ ^ true ].
	name := aString ifNil: [ self toggleNameFrom: aNode parent ].
	toggle := self ensureToggleNamed: name.
	toggle type: aNode nameToken source asSymbol.
	aNode attributeNamed: #toggle put: toggle.
	currentFile addEntity: toggle.
	self storeAST: aNode parent into: toggle.
	self addSourceFor: aNode parent to: toggle.
	((aNode parent parent isKindOf: PyFunctionCallExpressionNode)
		or: [ aNode parent parent isKindOf: PyFieldAccessExpressionNode ])
		ifTrue: [ self createUse: aNode parent parent of: toggle ]
		ifFalse: [ self registerSearchForNode: aNode parent parent to: toggle ].
	^ true
]

{ #category : #importing }
Gt4EdxImporter >> createUse: useNode of: toggle [
	| use |
	use := Gt4EdxToggleUse new.
	model add: use.
	currentFile addEntity: use.
	use definition: toggle.
	self storeAST: useNode into: use.
	self addSourceFor: useNode to: use
]

{ #category : #importing }
Gt4EdxImporter >> ensureFileNamed: aFileReference [
	| filename |
	filename := aFileReference pathString.
	DiskStore activeClass isCaseSensitive
		ifFalse: [ filename := filename asUppercase ].
	^ files
		at: filename
		ifAbsentPut: [ | file |
			file := FAMIXFile new.
			file name: aFileReference basename.
			aFileReference exists
				ifTrue: [ | encoding anchor |
					encoding := [ aFileReference
						binaryReadStreamDo: [ :in | (ZnCharacterEncoder detectEncoding: in upToEnd) identifier ] ]
						on: Error
						do: [ :ex | ex return: 'utf-8' ].
					anchor := FAMIXIndexedFileEntityAnchor
						file: file
						startPos: 1
						endPos:
							(aFileReference
								readStreamEncoded: encoding
								do: [ :stream | stream contents size ])
						model: model.
					file sourceAnchor: anchor ]
				ifFalse: [ file isStub: true ].
			(self ensureFolderNamed: aFileReference parent)
				ifNotNil: [ :folder | folder addChildFileSystemEntity: file ].
			model add: file.
			file ]
]

{ #category : #importing }
Gt4EdxImporter >> ensureFolderNamed: aFileReference [
	^ folders
		at: aFileReference pathString
		ifAbsentPut: [ | folder |
			folder := FAMIXFolder new.
			aFileReference = model rootFolder
				ifTrue: [ folder name: '.' ]
				ifFalse: [ folder name: aFileReference basename.
					(self ensureFolderNamed: aFileReference parent)
						ifNotNil: [ :outer | outer addChildFileSystemEntity: folder ] ].
			model add: folder.
			folder ]
]

{ #category : #importing }
Gt4EdxImporter >> ensureToggleNamed: aString [
	^ toggles
		at: aString
		ifAbsentPut: [ | toggle |
			toggle := Gt4EdxToggleDefinition new.
			toggle name: aString.
			model add: toggle.
			toggle ]
]

{ #category : #importing }
Gt4EdxImporter >> firstNodeAfter: anInteger in: aNode [
	aNode
		allNodesDo: [ :each | 
			(each startPosition > anInteger and: [ each stopPosition > anInteger ])
				ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : #importing }
Gt4EdxImporter >> importASTs: aCollection [
	aCollection do: [ :each | self importTogglesIn: each ].
	aCollection do: [ :each | self importUsesIn: each ].
	model sourceLanguage: FAMIXPythonSourceLanguage new
]

{ #category : #importing }
Gt4EdxImporter >> importCommentToggles: aNode [
	| source |
	source := aNode completeSource asString.
	aNode comments
		keysAndValuesDo:
			[ :i :each | 
			| comment index name toggle |
			comment := source copyFrom: each first to: each last.
			index := comment indexOfSubCollection: 'toggle_name: '.
			index = 0 ifTrue: [ index := index := comment indexOfSubCollection: 'setting_name: ' ].
			index > 0
				ifTrue:
					[ name := (comment allButFirst: (comment indexOf: $  startingAt: index)) trim.
					index := name indexOf: $ .
					index > 0 ifTrue: [ name := name first: index - 1 ].
					toggle := self ensureToggleNamed: name.
					(self firstNodeAfter: each last in: aNode)
						ifNotNil:
							[ :node | 
							| j famixComment |
							j := i.
							[ j <= aNode comments size and: [ (aNode comments at: j) first < node startPosition ] ] whileTrue: [ j := j + 1 ].
							i
								to: (j min: aNode comments size)
								do:
									[ :k | 
									famixComment := FAMIXComment new.
									famixComment content: (source copyFrom: (aNode comments at: k) first to: (aNode comments at: k) last).
									model add: famixComment.
									currentFile addEntity: famixComment.
									toggle addComment: famixComment ].
							(self importConstructedToggles: node named: name)
								ifFalse:
									[ self addSourceFor: node to: toggle.
									self storeAST: node into: toggle.
									node attributeNamed: #toggle put: toggle.
									self registerSearchForNode: node to: toggle ] ] ] ]
]

{ #category : #importing }
Gt4EdxImporter >> importConstructedToggles: aNode named: aString [
	| created |
	created := false.
	aNode
		withAllNodesOfType: PyVariableExpressionNode
		do: [ :each | 
			(#('LegacyWaffleFlag' 'LegacyWaffleSwitch' 'WaffleFlag' 'WaffleSwitch' 'SettingToggle' 'SettingDictToggle' 'ExperimentWaffleFlag')
				includes: each nameToken source)
				ifTrue: [ created := created | (self createToggle: each named: aString) ] ].
	^ created
]

{ #category : #importing }
Gt4EdxImporter >> importDocumentCommentToggles: aNode [
	aNode
		withAllNodesOfType: PyStringNode
		do:
			[ :each | 
			(each value source beginsWith: '"""')
				ifTrue:
					[ | comment index name toggle |
					comment := each value source.
					index := comment indexOfSubCollection: 'toggle_name: '.
					index = 0 ifTrue: [ index := index := comment indexOfSubCollection: 'setting_name: ' ].
					index > 0
						ifTrue:
							[ name := comment allButFirst: (comment indexOf: $  startingAt: index).
							name := (name first: (name indexOf: Character lf ifAbsent: [ name size - 3 ])) trim.
							index := name indexOf: $ .
							index > 0 ifTrue: [ name := name first: index - 1 ].
							toggle := self ensureToggleNamed: name.
							(self firstNodeAfter: each stopPosition in: aNode)
								ifNotNil:
									[ :node | 
									| famixComment |
									famixComment := FAMIXComment new.
									famixComment content: each value source.
									model add: famixComment.
									currentFile addEntity: famixComment.
									toggle addComment: famixComment.
									(self importConstructedToggles: node named: name)
										ifFalse:
											[ self addSourceFor: node to: toggle.
											self storeAST: node into: toggle.
											node attributeNamed: #toggle put: toggle.
											self registerSearchForNode: node to: toggle ] ] ] ] ]
]

{ #category : #importing }
Gt4EdxImporter >> importFeatureToggles: aNode [
	aNode
		withAllNodesOfType: PyAssignmentStatementNode
		do: [ :each | each lhs source = 'FEATURES' ifTrue: [ self importTogglesInFeatures: each ] ]
]

{ #category : #importing }
Gt4EdxImporter >> importTogglesIn: aNode [
	currentFile := self ensureFileNamed: aNode filename asFileReference.
	aNode attributeNamed: #entity put: currentFile.
	self storeAST: aNode into: currentFile.
	self importCommentToggles: aNode.
	self importDocumentCommentToggles: aNode.
	self importFeatureToggles: aNode.
	self importConstructedToggles: aNode named: nil
]

{ #category : #importing }
Gt4EdxImporter >> importTogglesInFeatures: aNode [
	aNode
		withAllNodesOfType: PyDictionaryExpressionNode
		do: [ :node | 
			node expressions
				do: [ :each | 
					(each object attributeNamed: #toggle)
						ifNil: [ | toggle source |
							toggle := self
									ensureToggleNamed: 'FEATURES[''' , (self removeQuotes: each object source) , ''']'.
							source := aNode topParent completeSource asString.
							each object commentsBefore
								do: [ :comment | 
									| famixComment |
									famixComment := FAMIXComment new.
									famixComment content: (source copyFrom: comment first to: comment last).
									model add: famixComment.
									currentFile addEntity: famixComment.
									toggle addComment: famixComment ].
							self addSourceFor: each object to: toggle.
							self storeAST: each object into: toggle.
							each object attributeNamed: #toggle put: toggle.
							self registerSearchForNode: each object to: toggle ]
						ifNotNil: [ :toggle | 
							| name |
							name := self removeQuotes: each object source.
							(name = toggle name
								or: [ (toggle name indexOfSubCollection: '''' , name , '''') > 0 ])
								ifFalse: [ toggle invalidName: true ] ] ] ]
]

{ #category : #importing }
Gt4EdxImporter >> importUsesIn: aNode [
	currentFile := self ensureFileNamed: aNode filename asFileReference.
	aNode
		withAllNodesDo: [ :each | 
			(each isKindOf: PyVariableExpressionNode)
				ifTrue: [ (variableSearches at: each source ifAbsent: [ #() ])
						do: [ :toggle | self createUse: each of: toggle ] ].
			(each isKindOf: PyFieldAccessExpressionNode)
				ifTrue: [ (variableSearches at: each nameToken source ifAbsent: [ #() ])
						do: [ :toggle | self createUse: each of: toggle ] ].
			(each isKindOf: PyStringNode)
				ifTrue: [ (stringSearches at: (self removeQuotes: each value source) ifAbsent: [ #() ])
						do: [ :toggle | self createUse: each of: toggle ] ] ]
]

{ #category : #initialization }
Gt4EdxImporter >> initialize [
	super initialize.
	model := MooseModel new.
	folders := Dictionary new.
	files := Dictionary new.
	toggles := Dictionary new.
	stringSearches := Dictionary new.
	variableSearches := Dictionary new
]

{ #category : #accessing }
Gt4EdxImporter >> model [
	^ model
]

{ #category : #importing }
Gt4EdxImporter >> namespaceNameFor: aNode [
	^ aNode source
]

{ #category : #parsing }
Gt4EdxImporter >> parseDirectory: aString [
	self baseDirectory: aString.
	^ (PythonParser sourceFilesIn: aString)
		collect: [ :each | self parseFile: each ]
]

{ #category : #parsing }
Gt4EdxImporter >> parseFile: aFile [
	| ast fileRef |
	fileRef := aFile asFileReference.
	ast := PythonParser parseWithErrors: fileRef contents.
	ast filename: fileRef pathString.
	^ ast
]

{ #category : #importing }
Gt4EdxImporter >> registerSearchForNode: aNode to: toggle [
	| node |
	node := aNode.
	(node isKindOf: PyExpressionStatementNode) ifTrue: [ node := node expression ].
	(node isKindOf: PyDictionaryExpressionNode)
		ifTrue: [ node expressions
				do: [ :each | self registerSearchForNode: each object to: toggle ] ].
	(node isKindOf: PyReturnStatementNode)
		ifTrue: [ node := node parentOfType: PyFunctionDefinitionNode ].
	(node isKindOf: PyAssignmentStatementNode)
		ifTrue: [ ^ (variableSearches at: node lhs source ifAbsentPut: [ OrderedCollection new ])
				add: toggle ].
	(node isKindOf: PyArgumentNode)
		ifTrue: [ ^ (variableSearches
				at: node name source
				ifAbsentPut: [ OrderedCollection new ]) add: toggle ].
	(node isKindOf: PyStringNode)
		ifTrue: [ ^ (stringSearches
				at: (self removeQuotes: node source)
				ifAbsentPut: [ OrderedCollection new ]) add: toggle ].
	(node isKindOf: PyVariableExpressionNode)
		ifTrue: [ ^ (variableSearches at: node source ifAbsentPut: [ OrderedCollection new ])
				add: toggle ].
	(node isKindOf: PyFunctionDefinitionNode)
		ifTrue: [ ^ (variableSearches
				at: node fname source
				ifAbsentPut: [ OrderedCollection new ]) add: toggle ]
]

{ #category : #importing }
Gt4EdxImporter >> removeQuotes: aString [
	^ ('''"' includes: aString first)
		ifTrue: [ aString copyFrom: 2 to: aString size - 1 ]
		ifFalse: [ aString ]
]

{ #category : #importing }
Gt4EdxImporter >> sourceAnchorFor: aNode [
	^ FAMIXIndexedFileEntityAnchor
		file: currentFile
		startPos: aNode startPosition
		endPos: aNode stopPosition
		model: model
]

{ #category : #importing }
Gt4EdxImporter >> storeAST: aNode into: anEntity [
	anEntity propertyNamed: #ast put: aNode
]

{ #category : #importing }
Gt4EdxImporter >> toggleNameFrom: aNode [
	| args |
	args := aNode arguments.
	args size = 5
		ifTrue: [ aNode receiver source = 'ExperimentWaffleFlag'
				ifTrue: [ ^ (self removeQuotes: (self argumentValue: args first) source) , '.'
						, (self removeQuotes: (self argumentValue: args second) source) ]
				ifFalse: [ ^ self
						removeQuotes: (self
								namespaceNameFor: ((args first isKindOf: PyArgumentNode)
										ifTrue: [ args first value ]
										ifFalse: [ args first ])) ] ].
	(args size = 2 or: [ args size = 5 ])
		ifTrue: [ ^ self removeQuotes: (self namespaceNameFor: (self argumentValue: args first)) ].
	(args size = 4 or: [ args size = 3 ])
		ifTrue: [ ^ (self removeQuotes: (self argumentValue: args first) source) , '.'
				, (self removeQuotes: (self argumentValue: args second) source) ].
	self error: 'unknown toggle type'
]
