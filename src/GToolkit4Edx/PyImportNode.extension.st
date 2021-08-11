Extension { #name : #PyImportNode }

{ #category : #'*GToolkit4Edx' }
PyImportNode >> gtEdxLegacyExplanationFor: aView [
	<gtView>
	| isLegacy isSettings |
	isLegacy := isSettings := false.
	self names
		do: [ :name | 
			isLegacy := isLegacy
				or: [ #('LegacyWaffleFlag' 'LegacyWaffleSwitch') includes: name source ].
			isSettings := isSettings
				or: [ #('SettingToggle' 'SettingDictToggle') includes: name source ] ].
	(isLegacy or: [ isSettings ])
		ifFalse: [ aView empty ].
	^ aView explicit
		priority: 1;
		title: 'Legacy' translated;
		stencil: [ Gt4EdxLegacyExplainer onSource: self topParent completeSource ]
]
