Extension { #name : 'FAMIXFolder' }

{ #category : '*GToolkit4Edx' }
FAMIXFolder >> edxTopComponent [
	self isRoot ifTrue: [^ nil].
	self parentFolder isNil ifTrue: [^ nil].
	self parentFolder isRoot ifTrue: [^ self].
	^ self parentFolder edxTopComponent
]
