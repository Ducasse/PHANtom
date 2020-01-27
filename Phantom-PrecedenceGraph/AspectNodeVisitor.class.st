Class {
	#name : #AspectNodeVisitor,
	#superclass : #Object,
	#instVars : [
		'visitedNodes',
		'cycle',
		'lastVisited',
		'orderedNodes'
	],
	#category : 'Phantom-PrecedenceGraph'
}

{ #category : #accessing }
AspectNodeVisitor >> cycledDetected [
	^cycle
]

{ #category : #visiting }
AspectNodeVisitor >> detectCycleFrom: anAspectNode [ 
	(self visitedNodes includes: anAspectNode)
		ifTrue: [cycle := true]
		ifFalse: [
			self visitedNodes add: anAspectNode.
			anAspectNode subnodes do: [:node | self detectCycleFrom: node].
			self visitedNodes remove: anAspectNode].
]

{ #category : #'as yet unclassified' }
AspectNodeVisitor >> getTopologicalOrderFrom: rootNodes [
	rootNodes do: [:node | self visitInOrder: node].
	self orderedNodes withIndexDo: [:node :index | node precedence: index].
	^ self orderedNodes
]

{ #category : #'initialize-release' }
AspectNodeVisitor >> initialize [
	cycle := false
]

{ #category : #'as yet unclassified' }
AspectNodeVisitor >> orderedNodes [
	^ orderedNodes ifNil: [orderedNodes := OrderedCollection new]
]

{ #category : #'as yet unclassified' }
AspectNodeVisitor >> visitInOrder: aNode [
	(self visitedNodes includes: aNode) 
	ifFalse: [
		self visitedNodes add: aNode.
		aNode parents do: [:parentNode | self visitInOrder: parentNode].
		self orderedNodes add: aNode.
		]
]

{ #category : #accessing }
AspectNodeVisitor >> visitedNodes [
	^visitedNodes ifNil: [visitedNodes := Set new.]  
]
