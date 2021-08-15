Class {
	#name : 'Gt4EdxLegacyExplainer',
	#superclass : 'BrStencil',
	#instVars : [
		'source'
	],
	#category : 'GToolkit4Edx-Explainer'
}

{ #category : 'instance creation' }
Gt4EdxLegacyExplainer class >> onSource: aString [
	^ self new
		source: aString;
		yourself
]

{ #category : 'api - instantiation' }
Gt4EdxLegacyExplainer >> create [
	| mainContainer sourceEditor leftContainer rightContainer rightContainerLabel leftContainerLabel |
	mainContainer := BrHorizontalPane new
		matchParent;
		padding: (BlInsets all: 5).
	mainContainer explainer isExplanationHolder: true.
	leftContainer := BrVerticalPane new
		matchParent;
		padding: (BlInsets all: 5);
		margin: (BlInsets right: 20).
	rightContainer := BrVerticalPane new
		matchParent;
		padding: (BlInsets all: 5).
	leftContainerLabel := self explanationTextElement.
	rightContainerLabel := BrLabel new
		text:
			('Source:' asRopedText
				glamorousRegularFont;
				foreground: Color gray);
		aptitude: BrGlamorousLabelAptitude;
		margin:
			(BlInsets
				top: 0
				right: 0
				bottom: 5
				left: 5).
	sourceEditor := self sourceEditor.
	leftContainer addChild: leftContainerLabel.
	rightContainer addChild: rightContainerLabel.
	rightContainer addChild: sourceEditor.
	mainContainer addChild: leftContainer.
	mainContainer addChild: rightContainer.
	^ mainContainer
]

{ #category : 'api - instantiation' }
Gt4EdxLegacyExplainer >> explainerStyler [
	^ (GtSmaCCParserStyler forParser: PythonParser)
		stylerRules:
			{(GtSmaCCNodeStylerRule
				nodeClassName: #PyImportNode
				styleBlock: [ :styler :node :text | 
					node names
						do: [ :each | 
							(#('LegacyWaffleFlag' 'LegacyWaffleSwitch') includes: each source)
								ifTrue: [ (text from: each startPosition to: each stopPosition)
										attributes:
											{(BlTextHighlightAttribute
												paint: BrGlamorousColors errorBackgroundColor)} ].
							(#('SettingToggle' 'SettingDictToggle') includes: each source)
								ifTrue: [ (text from: each startPosition to: each stopPosition)
										attributes:
											{(BlTextHighlightAttribute
												paint: BrGlamorousColors successBackgroundColor)} ].
							(text from: each startPosition - 1 to: each startPosition - 1)
								attributes:
									{((GtYellowCircleExplanationTextAdornment
										forIdentifier: each source asSymbol)
										size: 0;
										yourself)} ] ])}
]

{ #category : 'api - instantiation' }
Gt4EdxLegacyExplainer >> explanationText [
	^ ('Code that uses ' asRopedText ,
		('LegacyWaffleFlag' asRopedText glamorousExplanationFor: #LegacyWaffleFlag) , 
		' or ' asRopedText ,
		('LegacyWaffleSwitch' asRopedText glamorousExplanationFor: #LegacyWaffleSwitch) , 
		' should be converted to use ' asRopedText ,
		('SettingToggle' asRopedText glamorousExplanationFor: #SettingToggle) ,
		' or ' asRopedText ,
		('SettingDictToggle' asRopedText glamorousExplanationFor: #SettingDictToggle) , 
		'.' asRopedText)
		glamorousRegularFont;
		fontSize: 16
]

{ #category : 'api - instantiation' }
Gt4EdxLegacyExplainer >> explanationTextElement [
	^ (BrEditor new
		aptitude: (BrGlamorousEditorAptitude new lineSpacing: 5);
		hMatchParent;
		vFitContent;
		text: self explanationText) beReadOnlyWithSelection
		asScalableElement maxScale: 1
]

{ #category : 'accessing' }
Gt4EdxLegacyExplainer >> source [
	^ source
]

{ #category : 'accessing' }
Gt4EdxLegacyExplainer >> source: aString [
	source := aString
]

{ #category : 'api - instantiation' }
Gt4EdxLegacyExplainer >> sourceEditor [
	| sourceElement sourceContainer compositeStyler look |
	sourceContainer := BlElement new
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ];
		layout: BlLinearLayout vertical;
		margin: (BlInsets all: 10);
		background: Color white;
		aptitude: BrShadowAptitude.
	look := BrGlamorousCodeEditorAptitude new.
	sourceElement := BrEditor new.
	compositeStyler := GtCompositeSmaCCASTStyler forParser: PythonParser.
	compositeStyler
		stylers:
			{PythonParser gtStyler.
			self explainerStyler}.
	look styler: compositeStyler.
	sourceElement
		aptitude: look;
		styler: compositeStyler;
		text: source asRopedText.
	sourceContainer addChild: sourceElement.
	^ sourceContainer
]
