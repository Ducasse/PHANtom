Class {
	#name : #AspectNode,
	#superclass : #Object,
	#instVars : [
		'aspect',
		'subnodes',
		'name',
		'precedence',
		'parents'
	],
	#category : 'Phantom-PrecedenceGraph'
}

{ #category : #'as yet unclassified' }
AspectNode >> = anAspectNode [
	(anAspectNode isKindOf: AspectNode) ifFalse: [^false].
	^(self aspect = anAspectNode aspect)  
]

{ #category : #accessing }
AspectNode >> IncreasePrecedence [
	precedence := precedence  + 1.
	self subnodes do: [:node | node IncreasePrecedence]
]

{ #category : #accessing }
AspectNode >> addNode: anAspectNode [ 
	self subnodes add: anAspectNode
]

{ #category : #accessing }
AspectNode >> addNodes: anArray [ 
	anArray do: [:node | self addNode: node]
]

{ #category : #accessing }
AspectNode >> aspect [
	^ aspect. 
]

{ #category : #accessing }
AspectNode >> aspect: AspectClass [
	aspect := AspectClass
]

{ #category : #accessing }
AspectNode >> clearParents [
	self parents removeAll.
]

{ #category : #'as yet unclassified' }
AspectNode >> hash [
	^ self aspect hash.
]

{ #category : #'as yet unclassified' }
AspectNode >> initialize [
	super initialize.
	precedence := 0.
]

{ #category : #accessing }
AspectNode >> name: aString [
	name := aString
]

{ #category : #'as yet unclassified' }
AspectNode >> nodeName [
	^name
]

{ #category : #accessing }
AspectNode >> parents [
	^ parents ifNil: [parents := Set new.]  
]

{ #category : #accessing }
AspectNode >> precedence [
	^ precedence
]

{ #category : #'as yet unclassified' }
AspectNode >> precedence: aNumber [
	precedence := aNumber.
]

{ #category : #accessing }
AspectNode >> subnodes [
	^subnodes ifNil: [subnodes := Set new]  
]
