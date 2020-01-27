Class {
	#name : #PhantomDemoTrace,
	#superclass : #Object,
	#classVars : [
		'CallDepth',
		'TraceLevel',
		'TraceStream'
	],
	#category : 'Phantom-Examples'
}

{ #category : #'as yet unclassified' }
PhantomDemoTrace class >> initStream: aStream [
	TraceStream := aStream.
	CallDepth := 0.
]

{ #category : #'as yet unclassified' }
PhantomDemoTrace class >> initialize [
	TraceLevel := 0.
	CallDepth := 0.  
]

{ #category : #'as yet unclassified' }
PhantomDemoTrace class >> printEntering: aString [
	self printIdent.
	TraceStream nextPutAll: '--> ', aString.
	TraceStream nextPut: Character cr.      
]

{ #category : #'as yet unclassified' }
PhantomDemoTrace class >> printExiting: aString [
	self printIdent.
	TraceStream nextPutAll: '<-- ', aString.
	TraceStream nextPut: Character cr.      
]

{ #category : #'as yet unclassified' }
PhantomDemoTrace class >> printIdent [
	(CallDepth > 0) ifTrue: [(1 to: CallDepth) do: [:i | TraceStream nextPutAll: '	']]
]

{ #category : #'as yet unclassified' }
PhantomDemoTrace class >> traceEntry: aString [
	(TraceLevel > 0) ifTrue: [
		(TraceLevel = 2) ifTrue: [CallDepth := CallDepth +1].
		self printEntering: aString]  
]

{ #category : #'as yet unclassified' }
PhantomDemoTrace class >> traceExit: aString [
	(TraceLevel > 0) ifTrue: [
		self printExiting: aString.
		(TraceLevel = 2) ifTrue: [CallDepth := CallDepth -1]]  
]

{ #category : #'as yet unclassified' }
PhantomDemoTrace class >> traceStream [
	^TraceStream
]

{ #category : #accessing }
PhantomDemoTrace class >> tracelevel [
	^ TraceLevel
]

{ #category : #accessing }
PhantomDemoTrace class >> tracelevel: anObject [
	TraceLevel := anObject
]
