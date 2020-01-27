Class {
	#name : #PhantomDemoSquare,
	#superclass : #PhantomDemoTwoDShape,
	#instVars : [
		's'
	],
	#category : 'Phantom-Examples'
}

{ #category : #'as yet unclassified' }
PhantomDemoSquare class >> new [
	^self x: 0.0 y: 0.0 s: 1.0
]

{ #category : #'as yet unclassified' }
PhantomDemoSquare class >> s: side [
	^self x: 0.0 y: 0.0 s: side
]

{ #category : #'as yet unclassified' }
PhantomDemoSquare class >> x: xcoord y: ycoord [
	^self x: xcoord y: ycoord s: 1.0
]

{ #category : #'as yet unclassified' }
PhantomDemoSquare class >> x: xcoord y: ycoord s: side [
	^(super x: xcoord y: ycoord)
		s: side;
		yourself
]

{ #category : #'as yet unclassified' }
PhantomDemoSquare >> area [
	^ s raisedTo: 2.  
]

{ #category : #'as yet unclassified' }
PhantomDemoSquare >> perimeter [
	^ 4 * s.
]

{ #category : #'as yet unclassified' }
PhantomDemoSquare >> printOn: aStream [
	aStream
		nextPutAll: 'Squeare side = ';
		nextPutAll: s asString.
	super printOn: aStream.        
]

{ #category : #accessing }
PhantomDemoSquare >> s [
	^ s
]

{ #category : #accessing }
PhantomDemoSquare >> s: anObject [
	s := anObject
]
