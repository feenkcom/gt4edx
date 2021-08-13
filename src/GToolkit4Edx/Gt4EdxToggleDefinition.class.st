Class {
	#name : #Gt4EdxToggleDefinition,
	#superclass : #FAMIXNamedEntity,
	#instVars : [
		'uses'
	],
	#category : #'GToolkit4Edx-Model'
}

{ #category : #accessing }
Gt4EdxToggleDefinition >> initialize [
	super initialize.
	uses := FMMultivalueLink on: self opposite: #definition:
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
