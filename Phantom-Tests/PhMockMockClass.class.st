Class {
	#name : #PhMockMockClass,
	#superclass : #Object,
	#instVars : [
		'counter',
		'testString'
	],
	#category : 'Phantom-Tests'
}

{ #category : #'as yet unclassified' }
PhMockMockClass >> callTestMock [
	^ PhMockClass new test
]
