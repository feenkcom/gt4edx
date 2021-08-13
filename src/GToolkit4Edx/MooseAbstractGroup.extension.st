Extension { #name : #MooseAbstractGroup }

{ #category : #'*GToolkit4Edx' }
MooseAbstractGroup >> allEdxToggles [
	<navigation: 'All Toggles'>
	^ self allWithType: Gt4EdxToggleDefinition
]
