Class {
	#name : 'BaselineOfGToolkit4Edx',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGToolkit4Edx'
}

{ #category : 'accessing' }
BaselineOfGToolkit4Edx class >> loadLepiter [
	| currentProperties |
	currentProperties := LeDatabasesRegistry defaultLogicalDatabase properties.
	currentProperties
		addRegisteredDirectory: FileLocator imageDirectory
			/ 'pharo-local'
			/ 'iceberg'
			/ 'feenkcom'
			/ 'gt4edx'
			/ 'lepiter'.
	
	LeDatabasesRegistry default defaultLogicalDatabase reload.
]

{ #category : 'accessing' }
BaselineOfGToolkit4Edx >> baseline: spec [
	<baseline>
	spec
		for: #common do: [
			spec
				package: 'GToolkit4Edx' ]
]
