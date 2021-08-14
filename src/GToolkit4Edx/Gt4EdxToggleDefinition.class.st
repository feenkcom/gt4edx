Class {
	#name : #Gt4EdxToggleDefinition,
	#superclass : #FAMIXNamedEntity,
	#instVars : [
		'uses',
		'type'
	],
	#category : #'GToolkit4Edx-Model'
}

{ #category : #accessing }
Gt4EdxToggleDefinition >> initialize [
	super initialize.
	type := #DjangoSetting.
	uses := FMMultivalueLink on: self opposite: #definition:
]

{ #category : #testing }
Gt4EdxToggleDefinition >> isLegacy [
	^ type beginsWith: 'Legacy'
]

{ #category : #accessing }
Gt4EdxToggleDefinition >> type [
	^ type
]

{ #category : #accessing }
Gt4EdxToggleDefinition >> type: aSymbol [
	type := aSymbol
]

{ #category : #accessing }
Gt4EdxToggleDefinition >> uses [
	<MSEProperty: #uses type: #Gt4EdxToggleUse opposite: #definition>
	<multivalued>
	^ uses
]

{ #category : #accessing }
Gt4EdxToggleDefinition >> uses: aCollection [
	self uses value: aCollection
]
