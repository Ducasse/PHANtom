Class {
	#name : #ComparablePointDemoAspect,
	#superclass : #PhAspect,
	#category : 'Phantom-Examples'
}

{ #category : #'as yet unclassified' }
ComparablePointDemoAspect >> initialize [
	super initialize.
	self add: ((PhAdvice new)
			pointcut: ((PhPointcut new)
				receivers: 'PhantomDemoPoint';
				selectors: 'doesNotUnderstand:';
				context: #(#receiver #arguments));
			advice: [ :context | 
					(context arguments at: 1) selector = #compareTo:
						ifTrue: [ context receiver rho - ((context arguments at: 1) arguments at: 1) rho ] ];
			type: #around)
]
