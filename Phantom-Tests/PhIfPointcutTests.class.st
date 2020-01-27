Class {
	#name : #PhIfPointcutTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'as yet unclassified' }
PhIfPointcutTests >> testCombinedIfPointcut [
	| alwaysFalsePc alwaysTruePc orPc andPc orAsp andAsp |
	alwaysFalsePc := PhPointcut
		receivers: 'PhMockClass'
		selectors: 'test'
		if: [:ctx | false].
	alwaysTruePc := PhPointcut
		receivers: 'PhMockClass'
		selectors: 'test'
		if: [:ctx | true].
	orPc := alwaysFalsePc | alwaysTruePc.
	andPc := alwaysTruePc & alwaysFalsePc.
	
	orAsp := PhAspect new
		add: (PhAdvice
			around: orPc
			advice: [:ctx | 'orOk']).
	andAsp := PhAspect new
		add: (PhAdvice
			around: andPc
			advice: [:ctx | 'orOk']).
	[orAsp install.
	self assert: (PhMockClass new test = 'orOk')] ensure: [orAsp uninstall].
	[andAsp install.
	self assert: (PhMockClass new test = 'test')] ensure: [andAsp uninstall].
]

{ #category : #'as yet unclassified' }
PhIfPointcutTests >> testCombinedIfPointcut2 [
	| pc ifpc adv asp |
	
	pc := PhPointcut receivers: 'PhMockClass' selectors: 'test'.
	ifpc:= PhPointcut receivers: 'PhMockClass' selectors: 'test:' context: #(arguments) if: [:ctx | (ctx arguments at: 1) = 'true'].
	adv := PhAdvice
		around: (ifpc | pc)
		advice: [:ctx |
			'ok'].
	asp := PhAspect new add: adv.
	[asp install.
	self assert: (PhMockClass new test = 'ok').
	self deny: ((PhMockClass new test: 'false') = 'ok').
	self assert: ((PhMockClass new test: 'true') = 'ok')] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhIfPointcutTests >> testContextIfPointcut [
	| asp |
	asp := PhAspect new
		add: (PhAdvice
			around: (PhPointcut
				receivers: 'PhMockClass'
				selectors: 'echo:'
				context: #(arguments)
				if: [:ctx |
					(ctx arguments at: 1) = 'active'])
			advice: [:ctx | 'ok']).
	[asp install.
	self assert: ((PhMockClass new echo: 'active') = 'ok').
	self assert: ((PhMockClass new echo: 'test') = 'test')] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhIfPointcutTests >> testEmptyContextFalseIfPointcut [
	| asp |
	asp := PhAspect new
		add: (PhAdvice
			around: (PhPointcut
				receivers: 'PhMockClass'
				selectors: 'test'
				if: [:ctx | false])
			advice: [:ctx | 'ok']).
	[asp install.
	self assert: (PhMockClass new test = 'test').
	self deny: (PhMockClass new test = 'ok')] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhIfPointcutTests >> testEmptyContextTrueIfPointcut [
	| asp |
	asp := PhAspect new
		add: (PhAdvice
			around: (PhPointcut
				receivers: 'PhMockClass'
				selectors: 'test'
				if: [:ctx | true])
			advice: [:ctx | 'ok']).
	[asp install.
	self assert: (PhMockClass new test = 'ok').
	self deny: (PhMockClass new test = 'test')] ensure: [asp uninstall]
]
