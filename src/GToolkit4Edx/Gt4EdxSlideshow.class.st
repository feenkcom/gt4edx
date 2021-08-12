Class {
	#name : #Gt4EdxSlideshow,
	#superclass : #Object,
	#instVars : [
		'fileSystem'
	],
	#category : #GToolkit4Edx
}

{ #category : #switch }
Gt4EdxSlideshow >> currentFileReference [
	| ref |
	ref := fileSystem / 'New'.
	ref exists
		ifFalse: [ ref writeStreamDo: [ :stream | stream nextPutAll: '"""
Toggles for accounts related code.
"""

from edx_toggles.toggles import WaffleFlag
from openedx.core.djangoapps.site_configuration import helpers as configuration_helpers

# .. toggle_name: order_history.redirect_to_microfrontend
# .. toggle_implementation: WaffleFlag
# .. toggle_default: False
# .. toggle_description: Supports staged rollout of a new micro-frontend-based implementation of the order history page.
# .. toggle_use_cases: temporary, open_edx
# .. toggle_creation_date: 2019-04-11
# .. toggle_target_removal_date: 2020-12-31
# .. toggle_warnings: Also set settings.ORDER_HISTORY_MICROFRONTEND_URL and site''s
#   ENABLE_ORDER_HISTORY_MICROFRONTEND.
# .. toggle_tickets: DEPR-17
REDIRECT_TO_ORDER_HISTORY_MICROFRONTEND = WaffleFlag(''order_history.redirect_to_microfrontend'', __name__)


def should_redirect_to_order_history_microfrontend():
    return (
        configuration_helpers.get_value(''ENABLE_ORDER_HISTORY_MICROFRONTEND'') and
        REDIRECT_TO_ORDER_HISTORY_MICROFRONTEND.is_enabled()
    )


# .. toggle_name: account.redirect_to_microfrontend
# .. toggle_implementation: WaffleFlag
# .. toggle_default: False
# .. toggle_description: Supports staged rollout of a new micro-frontend-based implementation of the account page.
#   Its action can be overridden using site''s ENABLE_ACCOUNT_MICROFRONTEND setting.
# .. toggle_use_cases: temporary, open_edx
# .. toggle_creation_date: 2019-04-30
# .. toggle_target_removal_date: 2021-12-31
# .. toggle_warnings: Also set settings.ACCOUNT_MICROFRONTEND_URL.
# .. toggle_tickets: DEPR-17
REDIRECT_TO_ACCOUNT_MICROFRONTEND = LWaffleFlag(''account.redirect_to_microfrontend'', __name__)


def should_redirect_to_account_microfrontend():
    return configuration_helpers.get_value(''ENABLE_ACCOUNT_MICROFRONTEND'',
                                           REDIRECT_TO_ACCOUNT_MICROFRONTEND.is_enabled())
' ] ].
	^ ref
]

{ #category : #switch }
Gt4EdxSlideshow >> currentNames [
	^ #('SettingToggle' 'SettingDictToggle' 'WaffleFlag' 'WaffleSwitch')
]

{ #category : #initialization }
Gt4EdxSlideshow >> initialize [
	super initialize.
	fileSystem := FileSystem memory workingDirectory
]

{ #category : #switch }
Gt4EdxSlideshow >> legacyFileReference [
	| ref |
	ref := fileSystem / 'Old'.
	ref exists
		ifFalse:
			[ ref writeStreamDo: [ :stream | stream nextPutAll: '"""
Toggles for accounts related code.
"""

from edx_toggles.toggles import LegacyWaffleFlag
from openedx.core.djangoapps.site_configuration import helpers as configuration_helpers

# .. toggle_name: order_history.redirect_to_microfrontend
# .. toggle_implementation: WaffleFlag
# .. toggle_default: False
# .. toggle_description: Supports staged rollout of a new micro-frontend-based implementation of the order history page.
# .. toggle_use_cases: temporary, open_edx
# .. toggle_creation_date: 2019-04-11
# .. toggle_target_removal_date: 2020-12-31
# .. toggle_warnings: Also set settings.ORDER_HISTORY_MICROFRONTEND_URL and site''s
#   ENABLE_ORDER_HISTORY_MICROFRONTEND.
# .. toggle_tickets: DEPR-17
REDIRECT_TO_ORDER_HISTORY_MICROFRONTEND = LegacyWaffleFlag(''order_history'', ''redirect_to_microfrontend'', __name__)


def should_redirect_to_order_history_microfrontend():
    return (
        configuration_helpers.get_value(''ENABLE_ORDER_HISTORY_MICROFRONTEND'') and
        REDIRECT_TO_ORDER_HISTORY_MICROFRONTEND.is_enabled()
    )


# .. toggle_name: account.redirect_to_microfrontend
# .. toggle_implementation: WaffleFlag
# .. toggle_default: False
# .. toggle_description: Supports staged rollout of a new micro-frontend-based implementation of the account page.
#   Its action can be overridden using site''s ENABLE_ACCOUNT_MICROFRONTEND setting.
# .. toggle_use_cases: temporary, open_edx
# .. toggle_creation_date: 2019-04-30
# .. toggle_target_removal_date: 2021-12-31
# .. toggle_warnings: Also set settings.ACCOUNT_MICROFRONTEND_URL.
# .. toggle_tickets: DEPR-17
REDIRECT_TO_ACCOUNT_MICROFRONTEND = LegacyWaffleFlag(''account'', ''redirect_to_microfrontend'', __name__)


def should_redirect_to_account_microfrontend():
    return configuration_helpers.get_value(''ENABLE_ACCOUNT_MICROFRONTEND'',
                                           REDIRECT_TO_ACCOUNT_MICROFRONTEND.is_enabled())
' ] ].
	^ ref
]

{ #category : #switch }
Gt4EdxSlideshow >> legacyNames [
	^ #('LegacyWaffleFlag' 'LegacyWaffleSwitch')
]

{ #category : #private }
Gt4EdxSlideshow >> sourceEditorFor: aFileReference styler: explainationStyler [
	| container sourceElement sourceContainer styler look label |
	container := BlElement new
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ];
		layout: BlLinearLayout vertical;
		margin: (BlInsets all: 10);
		background: Color white.
	label := BrLabel new
		aptitude: BrGlamorousLabelAptitude new;
		text: (aFileReference basename asRopedText foreground: Color gray).
	label margin: (BlInsets left: 15).
	label hMatchParent.
	container addChild: label.
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
	explainationStyler isNil
		ifTrue: [ styler := PythonParser2 gtStyler ]
		ifFalse: [ styler := GtCompositeSmaCCASTStyler forParser: PythonParser2.
			styler
				stylers:
					{PythonParser2 gtStyler.
					explainationStyler} ].
	look styler: styler.
	sourceElement
		aptitude: look;
		styler: styler;
		text: aFileReference contents asRopedText.
	sourceContainer addChild: sourceElement.
	container addChild: sourceContainer.
	^ container
]

{ #category : #switch }
Gt4EdxSlideshow >> style: aToken in: text [
	| isLegacy isCurrent |
	isLegacy := self legacyNames includes: aToken source.
	isLegacy
		ifTrue: [ (text from: aToken startPosition to: aToken stopPosition)
				attributes:
					{(BlTextHighlightAttribute
						paint: BrGlamorousColors errorBackgroundColor)} ].
	isCurrent := self currentNames includes: aToken source.
	isCurrent
		ifTrue: [ (text from: aToken startPosition to: aToken stopPosition)
				attributes:
					{(BlTextHighlightAttribute
						paint: BrGlamorousColors successBackgroundColor)} ].
	(isLegacy or: [ isCurrent ])
		ifTrue: [ (text from: aToken startPosition - 1 to: aToken startPosition - 1)
				attributes:
					{((GtYellowCircleExplanationTextAdornment
						forIdentifier: aToken source asSymbol)
						size: 0;
						yourself)} ].
	^ isLegacy or: [ isCurrent ]
]

{ #category : #switch }
Gt4EdxSlideshow >> switchElement [
	| element |
	element := BlElement new
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ];
		layout: BlLinearLayout horizontal;
		margin: (BlInsets all: 10);
		background: Color white;
		yourself.
	element
		addChild:
			(self
				sourceEditorFor: self legacyFileReference
				styler: self switchStyler);
		addChild:
			(self
				sourceEditorFor: self currentFileReference
				styler: self switchStyler).
	^ element
]

{ #category : #switch }
Gt4EdxSlideshow >> switchSlideFor: aSlide [
	<gtSlide>
	^ aSlide textAndElement
		priority: 1;
		newTextWithFormat: self switchText;
		elementWeight: 0.6;
		element: [ self switchElement ].
]

{ #category : #switch }
Gt4EdxSlideshow >> switchStyler [
	^ (GtSmaCCParserStyler forParser: PythonParser2)
		stylerRules:
			{(GtSmaCCNodeStylerRule
				nodeClassName: #PyImportNode
				styleBlock:
					[ :styler :node :text | node names do: [ :each | self style: each in: text ] ]).
			(GtSmaCCNodeStylerRule
				nodeClassName: #PySymbolNode
				styleBlock: [ :styler :node :text | 
					(self style: node nameToken in: text)
						ifTrue: [ (text from: node startPosition - 1 to: node startPosition - 1)
								attributes:
									{((GtYellowCircleExplanationTextAdornment forIdentifier: #constructor)
										size: 0;
										yourself)} ] ])}
]

{ #category : #switch }
Gt4EdxSlideshow >> switchText [
	^ ('The ' asRopedText ,
		('LegacyWaffleFlag' asRopedText glamorousExplanationFor: #LegacyWaffleFlag) , 
		' and ' asRopedText ,
		('LegacyWaffleSwitch' asRopedText glamorousExplanationFor: #LegacyWaffleSwitch) , 
		' references should be converted to use the ' asRopedText , 
		('WaffleFlag' asRopedText glamorousExplanationFor: #WaffleFlag) , 
		' and ' asRopedText , 
		('WaffleSwitch' asRopedText glamorousExplanationFor: #WaffleSwitch) , 
		'. ' asRopedText ,
		('Initialize' asRopedText glamorousExplanationFor: #constructor) , 
		' these new classes with a single string that includes the fully namespaced toggle name, including the period.' asRopedText)
		glamorousRegularFont;
		fontSize: 16
]
