Class {
	#name : #PhCflowPointcutTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'as yet unclassified' }
PhCflowPointcutTests >> testNestedCFlow [
       | tocalltestcall nestedtestcall testcall asp |
       tocalltestcall := PhPointcut new
               receivers: 'PhMockClass';
               selectors: 'toCallTest'.
       nestedtestcall := PhPointcut new
               receivers: 'PhMockClass';
               selectors: 'test';
               inCflowOf: tocalltestcall.
       testcall := PhPointcut new
               receivers: 'PhMockClass';
               selectors: 'test'.
       asp := PhAspect new add:
               (PhAdvice new
                       pointcut: (testcall & (nestedtestcall not));
                       advice: [:ctx | 'direct'];
                       type: #around).
       [asp install.
       self assert: (PhMockClass new test = 'direct').
       self assert: (PhMockClass new toCallTest = 'test')] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhCflowPointcutTests >> testNestedCFlow2 [
       | tocalltestcall directCall asp |
       tocalltestcall := PhPointcut new
               receivers: 'PhMockClass';
               selectors: 'toCallTest'.
       directCall := PhPointcut new
               receivers: 'PhMockClass';
               selectors: 'test';
               notInCflowOf: tocalltestcall.

       asp := PhAspect new add:
               (PhAdvice new
                       pointcut: directCall;
                       advice: [:ctx | 'direct'];
                       type: #around).
       [asp install.
       self assert: (PhMockClass new test = 'direct').
       self assert: (PhMockClass new toCallTest = 'test')] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhCflowPointcutTests >> testSimpleCFlow [
	| pc asp |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		inCflowOf: (PhPointcut receivers: 'PhMockClass' selectors: 'toCallTest').
	asp := PhAspect new add: 
		(PhAdvice new 
			pointcut: pc;
			advice: [:ctx | 'inCflowOf'];
			type: #around).
	[asp install.
	self assert: (PhMockClass new test = 'test').
	self assert: (PhMockClass new toCallTest = 'inCflowOf')] ensure: [asp uninstall]
]
