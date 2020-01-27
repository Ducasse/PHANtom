Class {
	#name : #AspectGraph,
	#superclass : #Object,
	#instVars : [
		'nodeSet'
	],
	#category : 'Phantom-PrecedenceGraph'
}

{ #category : #accessing }
AspectGraph >> add: anAspectNode [
	self nodeSet add: anAspectNode  
]

{ #category : #accessing }
AspectGraph >> addAll: anArray [ 
	anArray do: [:node | self add: node]
]

{ #category : #'as yet unclassified' }
AspectGraph >> existsCycle [
	self nodeSet do: [:node |
		| visitor |
		visitor := AspectNodeVisitor new.
		visitor detectCycleFrom: node.
		(visitor cycledDetected) ifTrue: [
			^true]].
	^false.
]

{ #category : #'as yet unclassified' }
AspectGraph >> getBaseNodes [
	| base |
	base := OrderedCollection new.
	self setParents.
	self nodeSet do: [:node |
		node subnodes isEmpty ifTrue: [base add: node]].
	^base 
]

{ #category : #'as yet unclassified' }
AspectGraph >> getRootNode [
	self setParents.
	self nodeSet do: [:node |
		node parents isEmpty ifTrue: [^node]].
]

{ #category : #'as yet unclassified' }
AspectGraph >> getRoots [
	| rootList |
	rootList := OrderedCollection new.
	self setParents.
	self nodeSet do: [:node |
		node parents isEmpty ifTrue: [rootList add: node]].
	^rootList 
]

{ #category : #'as yet unclassified' }
AspectGraph >> getTopologicalSort [
	| visit |
	self setParents.
	visit := AspectNodeVisitor new.
	^ visit getTopologicalOrderFrom: self getBaseNodes.
]

{ #category : #'as yet unclassified' }
AspectGraph >> merge: anAspectGraph [ 
	anAspectGraph nodeSet do: [:node | self add: node].
	anAspectGraph nodeSet do: [:node |
		node subnodes do: [:sub |
			(self nodeSet like: node) subnodes add: (self nodeSet like: sub)]].
	^self.
]

{ #category : #accessing }
AspectGraph >> nodeSet [
	^ nodeSet ifNil: [nodeSet := Set new]  
]

{ #category : #accessing }
AspectGraph >> nodeSet: anObject [
	nodeSet := anObject
]

{ #category : #accessing }
AspectGraph >> remove: anAspectNode [
	self nodeSet remove: anAspectNode  
]

{ #category : #'as yet unclassified' }
AspectGraph >> setParents [
	self nodeSet do: [:node 	| node clearParents].
	self nodeSet do: [:node |
		node subnodes do: [:sub |
			sub parents add: node]].
]

{ #category : #'as yet unclassified' }
AspectGraph >> setPrecedence [
	self getTopologicalSort.
]
