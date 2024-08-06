Class {
	#name : #Gt4EdxToggleUse,
	#superclass : #FAMIXSourcedEntity,
	#instVars : [
		'definition'
	],
	#category : #'GToolkit4Edx-Model'
}

{ #category : #accessing }
Gt4EdxToggleUse >> definition [
	<MSEProperty: #definition type: #Gt4EdxToggleDefinition opposite: #uses>
	^ definition
]

{ #category : #accessing }
Gt4EdxToggleUse >> definition: aDefinition [
	definition := FMMultivalueLink
		on: self
		update: #uses
		from: self definition
		to: aDefinition
]

{ #category : #accessing }
Gt4EdxToggleUse >> gtDefinitionSourceFor: aView [
	<gtView>
	^ aView forward
		title: 'Definition complete source';
		object: [ self definition ];
		view: #gtSourceFor:
]

{ #category : #accessing }
Gt4EdxToggleUse >> gtDisplayOn: aStream [
	aStream nextPutAll: (', ' join: (self containerFiles collect: #mooseName))
]
