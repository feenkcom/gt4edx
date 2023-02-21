Class {
	#name : #BaselineOfGToolkit4Edx,
	#superclass : #BaselineOf,
	#category : 'BaselineOfGToolkit4Edx'
}

{ #category : #accessing }
BaselineOfGToolkit4Edx class >> loadLepiter [
	LeDatabasesRegistry defaultLogicalDatabase
		addKnowledgebaseFromDirectory: FileLocator imageDirectory 
			/ 'pharo-local' 
			/ 'iceberg' 
			/ 'feenkcom' 
			/ 'gt4edx'
			/ 'lepiter'
]

{ #category : #accessing }
BaselineOfGToolkit4Edx >> baseline: spec [
	<baseline>
	spec
		for: #common do: [
			spec
				package: 'GToolkit4Edx' ]
]
