Class {
	#name : #AspectGraphTest,
	#superclass : #TestCase,
	#category : 'Phantom-PrecedenceGraphTests'
}

{ #category : #'as yet unclassified' }
AspectGraphTest >> testComplexHierarchy [
	| graph n1 n2 n3 n4 n5 n6 |
	graph := AspectGraph new.
	n1 := AspectNode new aspect: PhMockAspect1. n2 := AspectNode new aspect: PhMockAspect2. n3 := AspectNode new aspect: PhMockAspect3.
	n4 := AspectNode new aspect: PhMockAspect4. n5 := AspectNode new aspect: PhMockAspect5. n6 := AspectNode new aspect: PhMockAspect6.
	n6 addNodes: (Array with: n1 with: n3 with: n5).
	n1 addNodes: (Array with: n2 with: n3).
	n3 addNodes: (Array with: n2 with: n4 with: n5).
	n4 addNode: n2.
	n5 addNode: n4.    
	graph addAll: (Array with: n1 with: n2 with: n3 with: n4 with: n5 with: n6).
	"graph setPrecedence."
	graph getTopologicalSort.
	self assert: (n6 precedence < n1 precedence).
	self assert: ((n1 precedence < n2 precedence) & (n1 precedence < n3 precedence)).
	self assert: ((n3 precedence < n2 precedence) & (n3 precedence < n4 precedence) & (n3 precedence < n5 precedence)).
	self assert: (n4 precedence < n2 precedence).
	self assert: (n5 precedence < n4 precedence).
]

{ #category : #'as yet unclassified' }
AspectGraphTest >> testCycleDetection [
	| graph node1 node2 node3 |
	graph := AspectGraph new.
	node1 := AspectNode new
		aspect: PhMockAspect1.
	node2 := AspectNode new
		aspect: PhMockAspect2.
	node3 := AspectNode new
		aspect: PhMockAspect3.
	node1 addNode: node2.
	node1 addNode: node3.
	node3 addNode: node2.

	graph add: node1; add: node2; add: node3.
	self assert: (graph existsCycle = false).
	"add a cycle"
	node2 addNode: node3.
	self assert: (graph existsCycle = true).
]

{ #category : #'as yet unclassified' }
AspectGraphTest >> testDetectParents [
	| graph n1 n2 n3 n4 n5 n6 |
	graph := AspectGraph new.
	n1 := AspectNode new aspect: PhMockAspect1. n2 := AspectNode new aspect: PhMockAspect2. n3 := AspectNode new aspect: PhMockAspect3.
	n4 := AspectNode new aspect: PhMockAspect4. n5 := AspectNode new aspect: PhMockAspect5. n6 := AspectNode new aspect: PhMockAspect6.
	n6 addNodes: (Array with: n1 with: n3 with: n5).
	n1 addNodes: (Array with: n2 with: n3).
	n3 addNodes: (Array with: n2 with: n4 with: n5).
	n4 addNode: n2.
	n5 addNode: n4.    
	graph addAll: (Array with: n1 with: n2 with: n3 with: n4 with: n5 with: n6).
	graph setParents.
	self assert: (n1 parents size = 1).
	self assert: (n1 parents includes: n6).
	self assert: (n2 parents size = 3).
	self assert: ((n2 parents includes: n1) & (n2 parents includes: n3) & (n2 parents includes: n4)).
	self assert: (n3 parents size = 2).
	self assert: ((n3 parents includes: n6) & (n3 parents includes: n1)).
	self assert: (n4 parents size = 2).
	self assert: ((n4 parents includes: n3) & (n4 parents includes: n5)).
	self assert: (n5 parents size = 2).
	self assert: ((n5 parents includes: n3) & (n5 parents includes: n6)).
	self assert: (n6 parents size = 0)      
]

{ #category : #'as yet unclassified' }
AspectGraphTest >> testOneNodeCycleDetection [
	| graph node1|
	graph := AspectGraph new.
	node1 := AspectNode new aspect: PhMockAspect1.
	node1 addNode: node1.
	graph add: node1.
	self assert: (graph existsCycle = true).
]

{ #category : #'as yet unclassified' }
AspectGraphTest >> testRootDetection [
	| graph n1 n2 n3 n4 n5 n6 |
	graph := AspectGraph new.
	n1 := AspectNode new aspect: PhMockAspect1. n2 := AspectNode new aspect: PhMockAspect2. n3 := AspectNode new aspect: PhMockAspect3.
	n4 := AspectNode new aspect: PhMockAspect4. n5 := AspectNode new aspect: PhMockAspect5. n6 := AspectNode new aspect: PhMockAspect6.
	n6 addNodes: (Array with: n1 with: n2 with: n3 with: n4 with: n5).
	n1 addNodes: (Array with: n2 with: n5).
	n2 addNode: n3.
	n5 addNode: n4.
	graph addAll: (Array with: n1 with: n2 with: n3 with: n4 with: n5 with: n6).
	self assert: (graph getRootNode = n6).
	              
]

{ #category : #'as yet unclassified' }
AspectGraphTest >> testSimpleHierarchy [
	| graph n1 n2 n3 n4 |
	graph := AspectGraph new.
	n1 := AspectNode new aspect: PhMockAspect1.
	n2 := AspectNode new aspect: PhMockAspect2.
	n3 := AspectNode new aspect: PhMockAspect3.
	n4 := AspectNode new aspect: PhMockAspect4. 
	n1 addNodes: (Array with: n2 with: n3).
	n2 addNode: n4.
	graph addAll: (Array with: n1 with: n2 with: n3 with: n4).
	"graph setPrecedence."
	graph getTopologicalSort.
	self assert: ((n1 precedence < n2 precedence) & (n1 precedence < n3 precedence)).
	self assert: (n2 precedence < n4 precedence).
]
