Extension { #name : #FAMIXFile }

{ #category : #'*GToolkit4Edx' }
FAMIXFile >> edxTopComponent [
	self parentFolder isNil ifTrue: [ ^ nil ].
	^ self parentFolder edxTopComponent
]
