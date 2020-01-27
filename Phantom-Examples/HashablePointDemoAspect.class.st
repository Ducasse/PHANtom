Class {
	#name : #HashablePointDemoAspect,
	#superclass : #PhAspect,
	#category : 'Phantom-Examples'
}

{ #category : #'as yet unclassified' }
HashablePointDemoAspect >> hash: aContext [
	^((aContext receiver x + aContext receiver y) \\ SmallInteger maxVal)
]

{ #category : #'as yet unclassified' }
HashablePointDemoAspect >> initialize [
	super initialize.
	self
		add:
			((PhAdvice new)
				pointcut:
						((PhPointcut new)
								receivers: 'PhantomDemoPoint';
								selectors: 'hash';
								context: #(#receiver));
				send: #hash: to: self;
				type: #around).
	self
		add:
			((PhAdvice new)
				pointcut:
						((PhPointcut new)
								receivers: 'PhantomDemoPoint';
								selectors: '=';
								context: #(#receiver #arguments));
				advice: [ :context | (context receiver x = (context arguments at: 1) x & (context receiver y = (context arguments at: 1) y)) ];
				type: #around)
]
