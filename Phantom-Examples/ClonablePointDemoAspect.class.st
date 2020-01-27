Class {
	#name : #ClonablePointDemoAspect,
	#superclass : #PhAspect,
	#category : 'Phantom-Examples'
}

{ #category : #'as yet unclassified' }
ClonablePointDemoAspect >> initialize [
	super initialize.
	self add:  ((PhAdvice new)
					pointcut: ((PhPointcut new)
						receivers: 'PhantomDemoPoint';
						selectors: 'postCopy';
						context: #(#receiver));
					advice: [ :context | 
						context receiver makeRectangular.
						context receiver makePolar ];
					type: #before)
]
