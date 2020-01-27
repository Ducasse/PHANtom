Class {
	#name : #PhantomDemoTwoDShape,
	#superclass : #Object,
	#instVars : [
		'x',
		'y'
	],
	#category : 'Phantom-Examples'
}

{ #category : #'as yet unclassified' }
PhantomDemoTwoDShape class >> x: xcoord y: ycoord [
	^(super new)
		x: xcoord;
		y: ycoord; 
		yourself
]

{ #category : #'as yet unclassified' }
PhantomDemoTwoDShape >> area [
	self subclassResponsibility 
]

{ #category : #'as yet unclassified' }
PhantomDemoTwoDShape >> distance: aTwoDShape [
	| dx dy |
	dx := (aTwoDShape x - x) abs.
	dy := (aTwoDShape y - y) abs.
	^((dx raisedTo: 2) + (dy raisedTo: 2)) sqrt.
]

{ #category : #'as yet unclassified' }
PhantomDemoTwoDShape >> perimeter [
	self subclassResponsibility 
]

{ #category : #'as yet unclassified' }
PhantomDemoTwoDShape >> printOn: aStream [
	aStream
		nextPutAll: ' @ (';
		nextPutAll: x asString;
		nextPutAll: ', ';
		nextPutAll: y asString;
		nextPutAll: ') '        
	    
]

{ #category : #'as yet unclassified' }
PhantomDemoTwoDShape >> x [
	^x
]

{ #category : #accessing }
PhantomDemoTwoDShape >> x: anObject [
	x := anObject
]

{ #category : #'as yet unclassified' }
PhantomDemoTwoDShape >> y [
	^y
]

{ #category : #accessing }
PhantomDemoTwoDShape >> y: anObject [
	y := anObject
]
