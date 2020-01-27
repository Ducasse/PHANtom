Class {
	#name : #PhantomDemoPoint,
	#superclass : #Object,
	#instVars : [
		'x',
		'y',
		'theta',
		'rho',
		'rectangular',
		'polar'
	],
	#category : 'Phantom-Examples'
}

{ #category : #'as yet unclassified' }
PhantomDemoPoint class >> main [
	| p1 |
	p1 := self new.
	Transcript show: 'p1 = ', p1 asString; cr.
	p1 setRectangularWith: 5 and: 2.
	Transcript show: 'p1 = ', p1 asString; cr.
	p1 setPolarWith: (Float pi / 4.0) and: 1.0.
	Transcript show: 'p1 = ', p1 asString; cr.
	p1 setPolarWith: 0.3805 and: 5.385.
	Transcript show: 'p1 = ', p1 asString; cr.
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> initialize [
	super initialize.
	x := 0.
	y := 0.
	theta := 0.
	rho := 0.
	polar := true.
	rectangular := true.
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> makePolar [
	polar ifFalse: [
		theta := x arcTan: y.
		rho := y / (theta sin).
		polar := true.]  
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> makeRectangular [
	rectangular ifFalse: [
		x := rho * (theta sin).
		y := rho * (theta cos).
		rectangular := true]  
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> offsetWith: deltaX and: deltaY [
	self setRectangularWith: (x + deltaX) and: (y  + deltaY)   
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> printOn: aStream [
	aStream nextPutAll: '(', (self x asString), ', ', (self y asString), ')[', (self theta asString), ' : ', (self rho asString), ']'.   
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> rho [
	self makePolar.
	^rho
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> rotate: anAngle [
	self setPolarWith: (theta + anAngle) and: rho.   
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> setPolarWith: newTheta and: newRho [
	theta := newTheta.
	rho := newRho.
	rectangular := false.
	polar := true.
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> setRectangularWith: newX and: newY [
	x := newX.
	y := newY.
	rectangular := true.
	polar := false
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> theta [
	self makePolar.
	^theta
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> x [
	self makeRectangular.
	^x
]

{ #category : #'as yet unclassified' }
PhantomDemoPoint >> y [
	self makeRectangular.
	^y
]
