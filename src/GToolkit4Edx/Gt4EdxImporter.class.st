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
	(aNode parent isKindOf: PyPowerNode)
		ifFalse: [ ^ false ].
	aNode parent trailers isEmpty
		ifTrue: [ ^ false ].
	aNode parent trailers first lparenToken isNil
		ifTrue: [ ^ false ].
	(aNode attributeNamed: #toggle ifAbsent: [  ]) notNil
		ifTrue: [ ^ true ].
	name := aString ifNil: [ self toggleNameFrom: aNode parent ].
	toggle := self ensureToggleNamed: name.
	aNode attributeNamed: #toggle put: toggle.
	currentFile addEntity: toggle.
	self storeAST: aNode parent into: toggle.
	self addSourceFor: aNode parent to: toggle.
	aNode parent trailers size > 1
		ifTrue: [ self createUse: aNode parent trailers second of: toggle ]
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
	aCollection do: [ :each | self importUsesIn: each ]
]

{ #category : #importing }
Gt4EdxImporter >> importCommentToggles: aNode [
	| source |
	source := aNode completeSource asString.
	aNode comments
		keysAndValuesDo: [ :i :each | 
			| comment index name toggle |
			comment := source copyFrom: each first to: each last.
			index := comment indexOfSubCollection: 'toggle_name: '.
			index > 0
				ifTrue: [ name := (comment allButFirst: index + 12) trim.
					toggle := self ensureToggleNamed: name.
					(self firstNodeAfter: each last in: aNode)
						ifNotNil: [ :node | 
							(self importConstructedToggles: node named: name)
								ifFalse: [ | j famixComment |
									j := i.
									[ j <= aNode comments size
										and: [ (aNode comments at: j) first < node startPosition ] ]
										whileTrue: [ j := j + 1 ].
									i to: (j min: aNode comments size) do: [ :k | 
										famixComment := FAMIXComment new.
										famixComment
											content:
												(source
													copyFrom: (aNode comments at: k) first
													to: (aNode comments at: k) last).
										model add: famixComment.
										currentFile addEntity: famixComment.
										toggle addComment: famixComment ].
									self addSourceFor: node to: toggle.
									self registerSearchForNode: node to: toggle ] ] ] ]
]

{ #category : #importing }
Gt4EdxImporter >> importConstructedToggles: aNode named: aString [
	| created |
	created := false.
	aNode
		allNodesOfType: PySymbolNode
		do: [ :each | 
			(#('LegacyWaffleFlag' 'LegacyWaffleSwitch' 'WaffleFlag' 'WaffleSwitch' 'SettingToggle' 'SettingDictToggle' 'ExperimentWaffleFlag')
				includes: each nameToken source)
				ifTrue: [ created := created | (self createToggle: each named: aString) ] ].
	^ created
]

{ #category : #importing }
Gt4EdxImporter >> importTogglesIn: aNode [
	currentFile := self ensureFileNamed: aNode filename asFileReference.
	aNode attributeNamed: #entity put: currentFile.
	self storeAST: aNode into: currentFile.
	self importCommentToggles: aNode.
	self importConstructedToggles: aNode named: nil
]

{ #category : #importing }
Gt4EdxImporter >> importUsesIn: aNode [
	currentFile := self ensureFileNamed: aNode filename asFileReference.
	aNode
		allNodesDo: [ :each | 
			(each isKindOf: PySymbolNode)
				ifTrue: [ (variableSearches at: each source ifAbsent: [ #() ])
						do: [ :toggle | self createUse: each of: toggle ] ].
			((each isKindOf: PyTrailerNode) and: [ each nameToken notNil ])
				ifTrue: [ (variableSearches at: each nameToken source ifAbsent: [ #() ])
						do: [ :toggle | self createUse: each of: toggle ] ].
			(each isKindOf: PyStringNode)
				ifTrue: [ (stringSearches
						at: (self removeQuotes: each value source)
						ifAbsent: [ #() ])
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
	^ (PythonParser2 sourceFilesIn: aString)
		collect: [ :each | self parseFile: each ]
]

{ #category : #parsing }
Gt4EdxImporter >> parseFile: aFile [
	| ast fileRef |
	fileRef := aFile asFileReference.
	ast := PythonParser2 parseWithErrors: fileRef contents.
	ast filename: fileRef pathString.
	^ ast
]

{ #category : #importing }
Gt4EdxImporter >> registerSearchForNode: aNode to: toggle [
	| node |
	node := aNode.
	(node isKindOf: PySimpleStmtNode)
		ifTrue: [ node := node stmts first ].
	(node isKindOf: PyDictorsetmakerNode)
		ifTrue: [ node := node test ].
	(node isKindOf: PyMoreTestsNode)
		ifTrue: [ node := node test ].
	(node isKindOf: PyReturnNode)
		ifTrue: [ node := node parentOfType: PyFuncdefNode ].
	((node isKindOf: PyExprStmtNode) and: [ node assigns notEmpty ])
		ifTrue: [ ^ (variableSearches
				at: node testlist source
				ifAbsentPut: [ OrderedCollection new ]) add: toggle ].
	(node isKindOf: PyArgumentNode)
		ifTrue: [ ^ (variableSearches
				at: node test source
				ifAbsentPut: [ OrderedCollection new ]) add: toggle ].
	(node isKindOf: PyPowerNode)
		ifTrue: [ (node atom isKindOf: PyStringsNode)
				ifTrue: [ ^ (stringSearches
						at: (self removeQuotes: node source)
						ifAbsentPut: [ OrderedCollection new ]) add: toggle ].
			(node atom isKindOf: PySymbolNode)
				ifTrue: [ ^ (variableSearches
						at: node source
						ifAbsentPut: [ OrderedCollection new ]) add: toggle ] ].
	(node isKindOf: PyFuncdefNode)
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
	args := aNode trailers first arguments.
	args size = 5
		ifTrue: [ aNode atom source = 'ExperimentWaffleFlag'
				ifTrue: [ ^ (self
						removeQuotes: (args first test2 ifNil: [ args first test ]) source)
						, '.'
						,
							(self
								removeQuotes: (args second test2 ifNil: [ args second test ]) source) ]
				ifFalse: [ ^ self
						removeQuotes: (self namespaceNameFor: (args first test2 ifNil: [ args first test ])) ] ].
	(args size = 2 or: [ args size = 5 ])
		ifTrue: [ ^ self
				removeQuotes: (self namespaceNameFor: (args first test2 ifNil: [ args first test ])) ].
	(args size = 4 or: [ args size = 3 ])
		ifTrue: [ ^ (self
				removeQuotes: (args first test2 ifNil: [ args first test ]) source)
				, '.'
				,
					(self
						removeQuotes: (args second test2 ifNil: [ args second test ]) source) ].
	self error: 'unknown toggle type'
]
