Class {
	#name : #PhantomDemoClass,
	#superclass : #Object,
	#classVars : [
		'D'
	],
	#category : 'Phantom-Examples'
}

{ #category : #'as yet unclassified' }
PhantomDemoClass class >> go [
	D := self new.
	D foo: 1 object: D.
	Transcript show: (D bar: 3); cr.
		
]

{ #category : #'as yet unclassified' }
PhantomDemoClass >> bar: aNumber [
	Transcript show: ('Demo bar: ', aNumber asString); cr.
	^ 'Demo bar: ', aNumber asString
]

{ #category : #'as yet unclassified' }
PhantomDemoClass >> foo: aNumber object: anObject [
	Transcript show: ('Demo foo: ', aNumber asString, ' object: ', anObject asString); cr.
]
