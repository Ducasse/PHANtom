Class {
	#name : #PhantomDemoCircle,
	#superclass : #PhantomDemoTwoDShape,
	#instVars : [
		'r'
	],
	#category : 'Phantom-Examples'
}

{ #category : #'as yet unclassified' }
PhantomDemoCircle class >> new [
	^self x: 0.0 y: 0.0 r: 1.0
]

{ #category : #'as yet unclassified' }
PhantomDemoCircle class >> r: radio [
	^self x: 0.0 y: 0.0 r: radio
]

{ #category : #'as yet unclassified' }
PhantomDemoCircle class >> x: xcoord y: ycoord [
	^self x: xcoord y: ycoord r: 1.0
]

{ #category : #'as yet unclassified' }
PhantomDemoCircle class >> x: xcoord y: ycoord r: radio [
	^(super x: xcoord y: ycoord)
		r: radio;
		yourself
]

{ #category : #'as yet unclassified' }
PhantomDemoCircle >> area [
	^(Float pi * (r raisedTo: 2))
]

{ #category : #'as yet unclassified' }
PhantomDemoCircle >> perimeter [
	^(2 * Float pi * r)
]

{ #category : #'as yet unclassified' }
PhantomDemoCircle >> printOn: aStream [
	aStream
		nextPutAll: 'Circle radius = ';
		nextPutAll: r asString.
	super printOn: aStream.          
]

{ #category : #accessing }
PhantomDemoCircle >> r [
	^ r
]

{ #category : #accessing }
PhantomDemoCircle >> r: anObject [
	r := anObject
]
