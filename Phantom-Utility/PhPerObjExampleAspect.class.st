"
An example of per-object deployment. The following produces the array { 1 . 1 . 0}

| dep m1 m2 m3 |
dep := PhPerObjDeployAspect onClassPattern: 'PhMockClass class' instantiate: PhPerObjExampleAspect targetmethod: #target:.
m1 := PhMockClass new.
m2 := PhMockClass new.
dep uninstall.
m3 := PhMockClass new.
m1 plus.
{(m1 counter) . (m2 counter) . (m3 counter)} inspect

"
Class {
	#name : #PhPerObjExampleAspect,
	#superclass : #PhAspect,
	#instVars : [
		'target'
	],
	#category : 'Phantom-Utility'
}

{ #category : #'initialize-release' }
PhPerObjExampleAspect >> init [
	|plus|
	plus := PhPointcut receivers: 'PhMockClass' selectors: 'plus' context: #(receiver).

	self add: (PhAdvice after: plus
		advice: [:ctx | (ctx receiver = self target) ifFalse: [self target counter: (self target counter +1) ]] ).
	self install. 
]

{ #category : #accessing }
PhPerObjExampleAspect >> target [
	^ target
]

{ #category : #accessing }
PhPerObjExampleAspect >> target: anObject [
	target := anObject
]
