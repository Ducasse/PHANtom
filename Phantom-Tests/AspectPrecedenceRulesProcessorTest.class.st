Class {
	#name : #AspectPrecedenceRulesProcessorTest,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'graph-generation' }
AspectPrecedenceRulesProcessorTest >> testGraphGenerationLongCollection [
	| collection processor graph n1 n2 n3 n4 n5 n6 |
	processor := PhPrecedenceRulesProcessor new.
	collection := OrderedCollection new.
	n1 := AspectNode new aspect: PhMockAspect1.
	n2 := AspectNode new aspect: PhMockAspect2.
	n3 := AspectNode new aspect: PhMockAspect3.
	n4 := AspectNode new aspect: PhMockAspect4.
	n5 := AspectNode new aspect: PhMockAspect5.
	n6 := AspectNode new aspect: PhMockAspect6.
	collection add: (Set with: n1).
	collection add: (Set with: n2 with: n3).
	collection add: (Set with: n4 with: n5).
	collection add: (Set with: n6).
	graph := processor getGraphFrom: collection.
	self assert: (graph nodeSet size = 6).
	self assert: (graph nodeSet includes: n1).
	self assert: (graph nodeSet includes: n2).
	self assert: (graph nodeSet includes: n3).
	self assert: (graph nodeSet includes: n4).
	self assert: (graph nodeSet includes: n5).
	self assert: (graph nodeSet includes: n6).
	self assert: ((graph nodeSet like: n1) subnodes includes: n2).
	self assert: ((graph nodeSet like: n1) subnodes includes: n3).
	self assert: ((graph nodeSet like: n2) subnodes includes: n4).
	self assert: ((graph nodeSet like: n2) subnodes includes: n5).
	self assert: ((graph nodeSet like: n3) subnodes includes: n4).
	self assert: ((graph nodeSet like: n3) subnodes includes: n5).
	self assert: ((graph nodeSet like: n4) subnodes includes: n6).
	self assert: ((graph nodeSet like: n5) subnodes includes: n6).
	self assert: ((graph nodeSet like: n1) subnodes size = 2).
	self assert: ((graph nodeSet like: n2) subnodes size = 2).
	self assert: ((graph nodeSet like: n3) subnodes size = 2).
	self assert: ((graph nodeSet like: n4) subnodes size = 1).
	self assert: ((graph nodeSet like: n5) subnodes size = 1).
	self assert: ((graph nodeSet like: n6) subnodes size = 0).
]

{ #category : #'graph-generation' }
AspectPrecedenceRulesProcessorTest >> testGraphGenerationOneNodeMultiNodes [
	| collection processor graph n1 n2 n3 n4 |
	processor := PhPrecedenceRulesProcessor new.
	collection := OrderedCollection new.
	n1 := AspectNode new aspect: PhMockAspect1.
	n2 := AspectNode new aspect: PhMockAspect2.
	n3 := AspectNode new aspect: PhMockAspect3.
	n4 := AspectNode new aspect: PhMockAspect4.
	collection add: (Set with: n1).
	collection add: (Set with: n2 with: n3 with: n4).
	graph := processor getGraphFrom: collection.
	self assert: (graph nodeSet size = 4).
	self assert: (graph nodeSet includes: n1).
	self assert: (graph nodeSet includes: n2).
	self assert: (graph nodeSet includes: n3).
	self assert: (graph nodeSet includes: n4).
	self assert: ((graph nodeSet like: n1) subnodes includes: n2).
	self assert: ((graph nodeSet like: n1) subnodes includes: n3).
	self assert: ((graph nodeSet like: n1) subnodes includes: n4).
	self assert: ((graph nodeSet like: n1) subnodes size = 3).
]

{ #category : #'graph-generation' }
AspectPrecedenceRulesProcessorTest >> testGraphGenerationTwoNodes [
	| collection processor graph n1 n2 |
	processor := PhPrecedenceRulesProcessor new.
	collection := OrderedCollection new.
	n1 := AspectNode new aspect: PhMockAspect1.
	n2 := AspectNode new aspect: PhMockAspect2.
	collection add: (Set with: n1).
	collection add: (Set with: n2).
	graph := processor getGraphFrom: collection.
	self assert: (graph nodeSet size = 2).
	self assert: (graph nodeSet includes: n1).
	self assert: (graph nodeSet includes: n2).
	self assert: ((graph nodeSet like: n1) subnodes includes: n2).  
]

{ #category : #'graph-generation' }
AspectPrecedenceRulesProcessorTest >> testGraphMerge [
	| graph1 graph2 n1g1 n2 n1g2 n3 |
	n1g1 := AspectNode new aspect: PhMockAspect1.
	n2 := AspectNode new aspect: PhMockAspect2.
	n1g2 := AspectNode new aspect: PhMockAspect1.
	n3 := AspectNode new aspect: PhMockAspect3.
	n1g1 addNode: n2.
	n1g2 addNode: n3.
	graph1 := AspectGraph new.
	graph1 addAll: (Array with: n1g1 with: n2).
	graph2 := AspectGraph new.
	graph2 addAll: (Array with: n1g2 with: n3).
	graph1 merge: graph2.
	self assert: ((graph1 nodeSet like: n1g1) subnodes includes: n2).
	self assert: ((graph1 nodeSet like: n1g1) subnodes includes: n3).
	self assert: ((graph1 nodeSet like: n1g2) subnodes includes: n2).
	self assert: ((graph1 nodeSet like: n1g2) subnodes includes: n3).     
	self assert: ((graph1 nodeSet like: n1g1) subnodes size = 2).
]
