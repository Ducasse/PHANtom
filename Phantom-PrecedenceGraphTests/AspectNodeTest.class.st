Class {
	#name : #AspectNodeTest,
	#superclass : #TestCase,
	#category : 'Phantom-PrecedenceGraphTests'
}

{ #category : #'as yet unclassified' }
AspectNodeTest >> testEquality [
	| n1 n2 n3 |
	n1 := AspectNode new aspect: PhMockAspect1.
	n2 := AspectNode new aspect: PhMockAspect2.
	n3 := AspectNode new aspect: PhMockAspect2.
	self assert: (n1 = n1).
	self assert: (n2 = n2).
	self assert: (n2 = n3).
	self deny: (n1 = n2).
	self deny: (n1 = n3).  
]

{ #category : #'as yet unclassified' }
AspectNodeTest >> testEqualityHash [
	| n1 n2 n3 |
	n1 := AspectNode new aspect: PhMockAspect1.
	n2 := AspectNode new aspect: PhMockAspect2.
	n3 := AspectNode new aspect: PhMockAspect2.
	self assert: (n1 hash = n1 hash).
	self assert: (n2 hash = n2 hash).
	self assert: (n2 hash = n3 hash).
	self deny: (n1 hash = n2 hash).
	self deny: (n1 hash = n3 hash).  
]
