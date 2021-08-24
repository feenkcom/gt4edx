Extension { #name : 'FAMIXFolder' }

{ #category : '*GToolkit4Edx' }
FAMIXFolder >> edxTopComponent [

	self isRoot ifTrue: [ ^ nil ].
	self parentFolder isNil ifTrue: [ ^ nil ].
	self isEdxTopComponent ifTrue: [ ^ self ].
	^ self parentFolder edxTopComponent
]

{ #category : '*GToolkit4Edx' }
FAMIXFolder >> isEdxTopComponent [
	self parentFolder isNil ifTrue: [ ^ false ].
	^ self parentFolder isRoot
]
