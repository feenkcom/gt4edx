Class {
	#name : #BaselineOfGToolkit4Edx,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkit4Edx
}

{ #category : #accessing }
BaselineOfGToolkit4Edx >> baseline: spec [
	<baseline>
	spec
		for: #common do: [
			spec
				package: 'GToolkit4Edx' ]
]
