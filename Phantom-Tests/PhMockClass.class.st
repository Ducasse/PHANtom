Class {
	#name : #PhMockClass,
	#superclass : #Object,
	#instVars : [
		'counter',
		'testString'
	],
	#category : 'Phantom-Tests'
}

{ #category : #'as yet unclassified' }
PhMockClass >> adv [
	^ 'test'
]

{ #category : #'as yet unclassified' }
PhMockClass >> adv: aContext [
	^ 'test'
]

{ #category : #'test methods' }
PhMockClass >> bar [
	Transcript show: ' is '.
]

{ #category : #'as yet unclassified' }
PhMockClass >> callMethod2 [
	^ self method2
]

{ #category : #accessing }
PhMockClass >> counter [
	^counter
]

{ #category : #accessing }
PhMockClass >> counter: anObject [
	counter := anObject
]

{ #category : #'as yet unclassified' }
PhMockClass >> echo: aString [
	^aString
]

{ #category : #'as yet unclassified' }
PhMockClass >> foo [
]

{ #category : #'as yet unclassified' }
PhMockClass >> getSender: ctx [
	^ ctx sender
]

{ #category : #'initialize-release' }
PhMockClass >> initialize [
	testString := 'test'.
	counter := 0.
]

{ #category : #'as yet unclassified' }
PhMockClass >> method2 [
	 ^'mockBehavior' 
]

{ #category : #'test methods' }
PhMockClass >> minus [
	counter := counter -1
]

{ #category : #'test methods' }
PhMockClass >> plus [
	counter := counter +1
]

{ #category : #'test methods' }
PhMockClass >> test [
	^testString.
]

{ #category : #'test methods' }
PhMockClass >> test: aString [
	testString := aString.
]

{ #category : #accessing }
PhMockClass >> testString [
	^testString.
]

{ #category : #'as yet unclassified' }
PhMockClass >> toCallTest [
	^ self test
]
