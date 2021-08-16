Class {
	#name : 'Gt4EdxToggleDefinition',
	#superclass : 'FAMIXNamedEntity',
	#instVars : [
		'uses',
		'type',
		'invalidName'
	],
	#category : 'GToolkit4Edx-Model'
}

{ #category : 'testing' }
Gt4EdxToggleDefinition >> hasToggleComment [
	^ self comments anySatisfy: [ :each | (each content indexOfSubCollection: 'toggle_name') > 0 ]
]

{ #category : 'accessing' }
Gt4EdxToggleDefinition >> initialize [
	super initialize.
	type := #DjangoSetting.
	uses := FMMultivalueLink on: self opposite: #definition:.
	invalidName := false
]

{ #category : 'accessing' }
Gt4EdxToggleDefinition >> invalidName [
	^ invalidName
]

{ #category : 'accessing' }
Gt4EdxToggleDefinition >> invalidName: aBoolean [
	invalidName := aBoolean
]

{ #category : 'testing' }
Gt4EdxToggleDefinition >> isLegacy [
	^ type beginsWith: 'Legacy'
]

{ #category : 'accessing' }
Gt4EdxToggleDefinition >> type [
	^ type
]

{ #category : 'accessing' }
Gt4EdxToggleDefinition >> type: aSymbol [
	type := aSymbol
]

{ #category : 'accessing' }
Gt4EdxToggleDefinition >> uses [
	<MSEProperty: #uses type: #Gt4EdxToggleUse opposite: #definition>
	<multivalued>
	^ uses
]

{ #category : 'accessing' }
Gt4EdxToggleDefinition >> uses: aCollection [
	self uses value: aCollection
]
