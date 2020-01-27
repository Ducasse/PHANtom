Class {
	#name : #PhAspectTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'add-remove' }
PhAspectTests >> testAddAdvice [
| pc adv asp |
	pc := PhPointcut new
		receivers: 'PhMockClass'; 
		selectors: 'test'.
	adv := PhAdvice new
		advice: [:ctx | 'around'];
		pointcut: pc;
		type: #around.
	asp := PhAspect new.
	asp add: adv.
	self assert: (asp adviceCollection includes: adv).
	asp remove: adv.
	self deny: (asp adviceCollection includes: adv)
	
]

{ #category : #'add-remove' }
PhAspectTests >> testAddClassModifier [
| pc mod asp |
	pc := PhPointcut new
		receivers: 'PhMockClass'; 
		selectors: 'test'.
	mod := PhClassModifier new on: (PhPointcut receivers: 'PhMockClass' selectors: #any asParser).
	asp := PhAspect new.
	asp addClassModifier: mod.
	self assert: (asp classModifiers includes: mod).
	asp removeClassModifier: mod.
	self deny: (asp classModifiers includes: mod)
	
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testAdviceAsBlock [
	| mock  pc adv asp |
	mock := PhMockClass new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'foo'.
	adv := PhAdvice new
		advice: [:ctx | 'test'];
		pointcut: pc;  
		type: #around.
	asp := PhAspect new.
	asp add: adv.
	[asp install.
	self assert: (mock foo = 'test')] ensure: [asp uninstall]
]

{ #category : #'advice-manipulation' }
PhAspectTests >> testAdviceRemovalFromAfter [
	| asp1 asp2 pc mock |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'counter';
		context: #(#advice #receiver).
		
	asp1 := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context |
				context afterAdvice: #()];
			type: #before).
	asp2 := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver plus];
		type: #after).
	
	[asp2 install.
	mock := PhMockClass new.
	self assert: (mock counter = 0).
	self assert: (mock counter = 1).
	asp1 install.
	"asp1 will remove plus advice on counter"
	self assert: (mock counter = 2).
	self assert: (mock counter = 2)] ensure: [
	asp1 uninstall.
	asp2 uninstall.]
]

{ #category : #'advice-manipulation' }
PhAspectTests >> testAdviceRemovalFromAround [
	| asp1 asp2 pc mock |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'counter';
		context: #(#advice #receiver).
		
	asp1 := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context |
				context aroundAdvice: #()];
			type: #before).
	asp2 := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | 'foo'];
		type: #around).
	[asp2 install. 
	mock := PhMockClass new.
	self assert: (mock counter = 'foo').
	asp1 install.
	"asp1 will remove plus advice on counter"
	self assert: (mock counter = 0)] ensure: [
	asp1 uninstall.
	asp2 uninstall.]
]

{ #category : #'advice-manipulation' }
PhAspectTests >> testAdviceRemovalFromBefore [
	| asp1 asp2 pc mock |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'counter';
		context: #(#advice #receiver #proceed).
		
	asp1 := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context |
				context aroundAdvice: (context aroundAdvice allButFirst)];
			type: #before).
	asp2 := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver plus. context proceed];
		type: #around);
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context proceed];
		type: #around).
	[asp2 install.
	mock := PhMockClass new.
	self assert: (mock counter = 1).
	asp1 install.
	"asp1 will remove plus advice on counter"
	self assert: (mock counter = 1).
	self assert: (mock counter = 1)] ensure: [
	asp1 uninstall.
	asp2 uninstall.]
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testAdviceSendTo [
	| mock  pc adv asp |
	mock := PhMockClass new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'foo'.
	adv := PhAdvice new
		send: #adv: to: mock;
		pointcut: pc;  
		type: #around.
	asp := PhAspect new.
	asp add: adv.
	[asp install.
	self assert: (mock foo = 'test')] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testAfterAdvice [
	|pc test advAfter aspect mock |
	mock := PhMockClass new.
	self assert: (mock test = 'test').
	aspect := PhAspect new.
	pc := (PhPointcut new) receivers: 'PhMockClass'; selectors: 'test'; context: #(#receiver).
	advAfter := (PhAdvice new) advice: [:context | context receiver instVarNamed: 'testString' put: 'afterTest' ]; pointcut: pc; type: #after.  
	aspect add: advAfter.
	
	[aspect install.

	self assert: (mock test = 'test').
	self assert: (mock testString = 'afterTest')] ensure: [aspect uninstall]  
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testAroundAdvice [
	| pc adv asp mock |
	mock := PhMockClass new.
	pc := PhPointcut new
		receivers: 'PhMockClass'; 
		selectors: 'test'.
	adv := PhAdvice new
		advice: [:ctx | 'around'];
		pointcut: pc;
		type: #around.
	asp := PhAspect new.
	asp add: adv.
	
	[asp install.
	
	self assert: (mock test = 'around')] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testAroundAround [
	| pc advice innerAspect outerAspect mock |
	mock := PhMockClass new.
	pc := PhPointcut receivers: 'PhMockClass' selectors: 'method2' context: #(#receiver #proceed).
	advice := PhAdvice around: pc advice: [ :context | 'aspectualBehavior' ].
	innerAspect := PhAspect new add: advice.
	pc := PhPointcut receivers: 'PhMockClass' selectors: 'callMethod2' context: #(#receiver #proceed).
	advice := PhAdvice around: pc advice: [ :context | context proceed ].
	outerAspect := PhAspect new add: advice.
	[ 
	innerAspect install.
	outerAspect install.
	self assert: mock callMethod2 = 'aspectualBehavior' ]
		ensure: [ 
			innerAspect uninstall.
			outerAspect uninstall ]
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testAroundProceedAdvice [
	| pc adv asp mock |
	mock := PhMockClass new.
	pc := PhPointcut new
		receivers: 'PhMockClass'; 
		selectors: 'test';
		context: #(#proceed).  
	adv := PhAdvice new
		advice: [:context | 'around', context proceed];
		pointcut: pc;
		type: #around.
	asp := PhAspect new.
	asp add: adv.
	
	[asp install.
	
	self assert: (mock test = 'aroundtest')] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testAroundProceedWithArgsAdvice [
	| pc adv asp mock |
	mock := PhMockClass new.
	pc := PhPointcut new
		receivers: 'PhMockClass'; 
		selectors: 'echo:';
		context: #(#proceed #arguments).
	adv := PhAdvice new
		advice: [:context |  context proceed: (context arguments collect: [:a | a asUppercase])];
		pointcut: pc;
		type: #around.
	asp := PhAspect new.
	asp add: adv.
	
	[asp install.
	
	self assert: ((mock echo: 'test') = 'TEST')] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testBeforeAdvice [
	|pc advBefore aspect |
	self assert: ((PhMockClass new) test = 'test').
	aspect := PhAspect new.
	pc := (PhPointcut new) receivers: 'PhMockClass'; selectors: 'test'; context: #(#receiver).
	advBefore := (PhAdvice new) advice: [:context | context receiver instVarNamed: 'testString' put: 'beforeTest' ]; pointcut: pc; type: #before.  
	aspect add: advBefore.
	
	[aspect install.
	self assert: ((PhMockClass new) test = 'beforeTest')] ensure: [aspect uninstall].  
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testBeforeAfterAdvice [
	|pc beforeAdv advAfter aspect mock |

	mock := PhMockClass new.
	self assert: (mock test = 'test').
	aspect := PhAspect new.
	pc := (PhPointcut new) receivers: 'PhMockClass'; selectors: 'test'; context: #(#receiver).
	beforeAdv := (PhAdvice new) advice: [:context | context receiver instVarNamed: 'testString' put: ('before',(context receiver testString )) ]; pointcut: pc; type: #before.  
	advAfter := (PhAdvice new) advice: [:context | context receiver instVarNamed: 'testString' put: ((context receiver testString),'after') ]; pointcut: pc; type: #after.  
	aspect add: advAfter.
	aspect add: beforeAdv.
	[aspect install.
	self assert: (mock test = 'beforetest').  self assert: (mock testString = 'beforetestafter').] ensure: [aspect uninstall. ].
  	
	
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testCallAround [
	| pc advice innerAspect outerAspect mock |
	mock := PhMockClass new.
	pc := PhPointcut receivers: 'PhMockClass' selectors: 'method2' context: #(#receiver #proceed).
	advice := PhAdvice around: pc advice: [ :context | 'aspectualBehavior' ].
	innerAspect := PhAspect new add: advice.
	pc := PhPointcut receivers: 'PhMockClass' selectors: 'callMethod2' context: #(#receiver).
	advice := PhAdvice after: pc advice: [ :context | ].
	outerAspect := PhAspect new add: advice.
	[ 
	innerAspect install.
	outerAspect install.
	self assert: mock callMethod2 = 'aspectualBehavior' ]
		ensure: [ 
			innerAspect uninstall.
			outerAspect uninstall ]
]

{ #category : #'chained-proceed' }
PhAspectTests >> testChainedProceed1 [
	|  asp pc |
	asp := PhAspect new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#proceed).
	asp add: (PhAdvice new
		advice: [:context | 'test',context proceed];
		pointcut: pc;
		type: #around).
	asp add: (PhAdvice new
		advice: [:context | 'test',context proceed];
		pointcut: pc;
		type: #around).
	asp add: (PhAdvice new
		advice: [:context | 'test',context proceed];
		pointcut: pc;
		type: #around).
	
	[asp install.
	self assert: (PhMockClass new test = 'testtesttesttest')] ensure: [asp uninstall.]
]

{ #category : #'chained-proceed' }
PhAspectTests >> testChainedProceed2 [
	|  asp pc |
	asp := PhAspect new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#proceed).
	asp add: (PhAdvice new
		advice: [:context | 'bar'];
		pointcut: pc;
		type: #around).
	asp add: (PhAdvice new
		advice: [:context | 'foo',context proceed];
		pointcut: pc;
		type: #around).
	asp add: (PhAdvice new
		advice: [:context | 'test',context proceed];
		pointcut: pc;
		type: #around).
	
	[asp install.
	PhMockClass new test.
	self assert: (PhMockClass new test = 'bar')] ensure: [asp uninstall.]
]

{ #category : #'chained-proceed' }
PhAspectTests >> testChainedProceed3 [
	|  asp pc |
	asp := PhAspect new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#proceed).
	asp add: (PhAdvice new
		advice: [:context | context proceed];
		pointcut: pc;
		type: #around).
	asp add: (PhAdvice new
		advice: [:context | context proceed];
		pointcut: pc;
		type: #around).
	asp add: (PhAdvice new
		advice: [:context | 'bar',context proceed];
		pointcut: pc;
		type: #around).
	
	[asp install.
	self assert: (PhMockClass new test = 'bartest')] ensure: [asp uninstall.]
]

{ #category : #'chained-proceed' }
PhAspectTests >> testChainedProceed4 [
	|  asp pc |
	asp := PhAspect new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#proceed).
	asp add: (PhAdvice new
		advice: [:context | 'bar',context proceed];
		pointcut: pc;
		type: #around).
	
	[asp install.
	self assert: (PhMockClass new test = 'bartest')] ensure: [asp uninstall.]
]

{ #category : #'chained-proceed' }
PhAspectTests >> testChainedProceed5 [
	|  asp pc |
	asp := PhAspect new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#proceed).
	asp add: (PhAdvice new
		advice: [:context | 'asdf'. context proceed];
		pointcut: pc;
		type: #around).
	asp add: (PhAdvice new
		advice: [:context | 'foo',context proceed];
		pointcut: pc;
		type: #around).
	asp add: (PhAdvice new
		advice: [:context | 'bar',context proceed];
		pointcut: pc;
		type: #around).
	
	[asp install.
	self assert: (PhMockClass new test = 'foobartest')] ensure: [asp uninstall.]
]

{ #category : #'advice-manipulation' }
PhAspectTests >> testChangeCurrent [
	|pc asp1 asp2 asp3 |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'foo';
		context: #(#advice #proceed).
		
	asp1 := PhMockAspect1 new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context |
				| current | 
				current := context currentAdvice asOrderedCollection select: [:each | each owner class = PhMockAspect2].
				context currentAdvice: current continueAt: 1.
				context proceed];
			type: #around).
	asp2 := PhMockAspect2 new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | 'ok'];
			type: #around).
	asp3 := PhMockAspect3 new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | 'not', context proceed asString];
			type: #around);
		precedence: #('PhMockAspect1' 'PhMockAspect3' 'PhMockAspect2').
	
	[asp1 install.
	asp2 install.
	asp3 install.
	self assert: (PhMockClass new foo = 'ok')] ensure: [asp1 uninstall. asp2 uninstall. asp3 uninstall.]
]

{ #category : #'advice-manipulation' }
PhAspectTests >> testChangeOrder [
	|pc asp |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'foo';
		context: #(#advice).
		
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | 
				context aroundAdvice: (context aroundAdvice asArray reversed).
				context proceed.];
			type: #before);
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | 'bar'];
			type: #around);
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | 'foo'];
			type: #around).
	[asp install.
	self assert: (PhMockClass new foo = 'foo')] ensure: [asp uninstall.]
]

{ #category : #'advice-manipulation' }
PhAspectTests >> testCurrentAdviceRemove [
	| asp1 asp2 asp3 pc |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'testString';
		precedence: #('PhMockAspect1' 'PhMockAspect2' 'PhMockAspect3');
		context: #(#advice).
		
	asp1 := PhMockAspect1 new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context |
				| advices |
				advices := (context currentAdvice select: [:each | (each owner class = PhMockAspect2) not]).
				context currentAdvice: advices continueAt: (context currentAdviceIndex +1).
				context proceed];
			type: #around)..
	asp2 := PhMockAspect2 new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context |
				'foo'];
			type: #around).
	asp3 := PhMockAspect3 new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | 
				'bar'.];
			type: #around).
	
	  
	[asp2 install.
	asp3 install.
	self assert: (PhMockClass new testString = 'foo').
	asp1 install.
	self assert: (PhMockClass new testString = 'bar')
	] ensure: [
	asp1 uninstall.
	asp2 uninstall.
	asp3 uninstall]
]

{ #category : #'inherited-precedence' }
PhAspectTests >> testInheritedPrecedence [
	| asp1 asp2 asp3 asp4 asp5 asp6 pc |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#receiver).
	asp1 := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver test: 'asp1'];
			type: #before).
	asp2 := PhMockAspect1 new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver test: (context receiver testString), 'asp2'];
			type: #before).
	asp3 := PhMockAspectFoo1 new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver test: (context receiver testString), 'asp3'];
			type: #before).
	asp4 := PhMockFooAspect4 new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver test: (context receiver testString), 'asp4'];
			type: #before).
			
	  
	[
	asp4 install.
	asp3 install.
	asp2 install.
	asp1 install.
	self assert: (PhMockClass new test = 'asp1asp2asp3asp4')] ensure: [
	asp1 uninstall.
	asp2 uninstall.
	asp3 uninstall.
	asp4 uninstall.]
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testMultiAfterAdvice [
	| mock asp pc |
	mock := PhMockClass new.
	asp := PhAspect new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'counter';
		context: #(receiver).  
	asp add: (PhAdvice new
		advice: [:context | context receiver minus];
		pointcut: pc;
		type: #after).
	asp add: (PhAdvice new
		advice: [:context | context receiver minus];
		pointcut: pc;
		type: #after).
	asp add: (PhAdvice new
		advice: [:context | context receiver minus];
		pointcut: pc;
		type: #after).
	
	[asp install.
	
	self assert: (mock counter = 0).
	self assert: (mock counter = -3)] ensure: [asp uninstall.]
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testMultiAroundAdvice [
	| mock asp pc |
	mock := PhMockClass new.
	asp := PhAspect new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'plus';
		context: #(#receiver #proceed).
	asp add: (PhAdvice new
		advice: [:context | context receiver minus. context proceed];
		pointcut: pc;
		type: #around).
	asp add: (PhAdvice new
		advice: [:context | context receiver minus. context proceed];
		pointcut: pc;
		type: #around).
	asp add: (PhAdvice new
		advice: [:context | context receiver minus.];
		pointcut: pc;
		type: #around).
	
	[asp install.

	mock plus.
	self assert: (mock counter = -3)] ensure: [asp uninstall.]
]

{ #category : #'as yet unclassified' }
PhAspectTests >> testMultiBeforeAdvice [
	| mock asp pc |
	mock := PhMockClass new.
	asp := PhAspect new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'counter';
		context: #(#receiver).  
	asp add: (PhAdvice new
		advice: [:context | context receiver minus];
		pointcut: pc;
		type: #before).
	asp add: (PhAdvice new
		advice: [:context | context receiver minus];
		pointcut: pc;
		type: #before).
	asp add: (PhAdvice new
		advice: [:context | context receiver minus];
		pointcut: pc;
		type: #before).
	
	[asp install.
	
	self assert: (mock counter = -3)] ensure: [asp uninstall.]
]

{ #category : #'pointcut-precedence' }
PhAspectTests >> testPointcutCombinePrecedenceAfter [
	|pc aspect1 aspect2 aspect3 mock |
	mock := (PhMockClass new).
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#receiver);
		precedence: #('PhMockAspect1' 'PhMockAspect2').  
	aspect1 := PhMockAspect1 new 
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver test: ('asp1', context receiver testString)];
			type: #after);
		precedence: #('PhMockAspect3' 'PhMockAspect2').
	aspect2 := PhMockAspect2 new add: ( PhAdvice new 
		pointcut: pc;
		advice: [:context | context receiver test: ('asp2', context receiver testString)];
		type: #after).
	aspect3 := PhMockAspect3 new add: (PhAdvice new  
		pointcut: pc;
		advice: [:context | context receiver test: ('asp3', context receiver testString)];
		type: #after).
	
	[aspect1 install.
	aspect2 install.
	aspect3 install.
	mock test.
	self assert: (mock test = 'asp3asp1asp2test')] ensure: [
		aspect1 uninstall.
		aspect2 uninstall.
		aspect3 uninstall].  
]

{ #category : #'pointcut-precedence' }
PhAspectTests >> testPointcutOverridePrecedenceAfter [
	|pc aspect1 aspect2 aspect3 mock |
	mock := (PhMockClass new).
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#receiver);
		overridePrecedence: #('PhMockAspect1' 'PhMockAspect2' 'PhMockAspect3').  
	aspect1 := PhMockAspect1 new 
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver test: ('asp1', context receiver testString)];
			type: #after);
		precedence: #('PhMockAspect3' 'PhMockAspect1' 'PhMockAspect2').
	aspect2 := PhMockAspect2 new add: ( PhAdvice new 
		pointcut: pc;
		advice: [:context | context receiver test: ('asp2', context receiver testString)];
		type: #after).
	aspect3 := PhMockAspect3 new add: (PhAdvice new  
		pointcut: pc;
		advice: [:context | context receiver test: ('asp3', context receiver testString)];
		type: #after).
	
	[
	aspect1 install.
	aspect2 install.
	aspect3 install.
	mock test.
	self assert: (mock test = 'asp1asp2asp3test')] ensure: [
		aspect1 uninstall.
		aspect2 uninstall.
		aspect3 uninstall].  
]

{ #category : #'pointcut-precedence' }
PhAspectTests >> testPointcutPrecedenceAfter [
	|pc aspect1 aspect2 aspect3 mock |
	mock := (PhMockClass new).
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#receiver);
		precedence: #('PhMockAspect1' 'PhMockAspect2').  
	aspect1 := PhMockAspect1 new 
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver test: ('asp1', context receiver testString)];
			type: #after);
		precedence: #('PhMockAspect3' 'PhMockAspect2' 'PhMockAspect1').
	aspect2 := PhMockAspect2 new add: ( PhAdvice new 
		pointcut: pc;
		advice: [:context | context receiver test: ('asp2', context receiver testString)];
		type: #after).
	aspect3 := PhMockAspect3 new add: (PhAdvice new  
		pointcut: pc;
		advice: [:context | context receiver test: ('asp3', context receiver testString)];
		type: #after).
	
	[
	aspect1 install.
	aspect2 install.
	aspect3 install.
	mock test.
	self assert: (mock test = 'asp3asp1asp2test')] ensure: [
	aspect1 uninstall.
	aspect2 uninstall.
	aspect3 uninstall].  
]

{ #category : #precedence }
PhAspectTests >> testPrecedenceAfter [
	|pc aspect1 aspect2 aspect3 mock |
	mock := (PhMockClass new).
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#receiver).  
	aspect1 := PhMockAspect1 new 
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver test: ('asp1', context receiver testString)];
			type: #after);
		precedence: #('PhMockAspect3' 'PhMockAspect1' 'PhMockAspect2').
	aspect2 := PhMockAspect2 new add: ( PhAdvice new 
		pointcut: pc;
		advice: [:context | context receiver test: ('asp2', context receiver testString)];
		type: #after).
	aspect3 := PhMockAspect3 new add: (PhAdvice new  
		pointcut: pc;
		advice: [:context | context receiver test: ('asp3', context receiver testString)];
		type: #after).
	
	[
	aspect1 install.
	aspect2 install.
	aspect3 install.
	mock test.
	self assert: (mock test = 'asp3asp1asp2test')] ensure: [
		aspect1 uninstall.
		aspect2 uninstall.
		aspect3 uninstall].  
]

{ #category : #precedence }
PhAspectTests >> testPrecedenceAround [
	|pc aspect1 aspect2 aspect3 |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(proceed).
	aspect1 := PhMockAspect1 new 
		add: (PhAdvice new  
			pointcut: pc;
			advice: [:ctx | 'asp1',ctx proceed.];
			type: #around);
		precedence: #('PhMockAspect3' 'PhMockAspect1' 'PhMockAspect2').
	aspect2 := PhMockAspect2 new add: (PhAdvice new  
		pointcut: pc;
		advice: [:ctx | 'asp2'];
		type: #around).
	aspect3 := PhMockAspect3 new add: (PhAdvice new
		pointcut: pc;
		advice: [:ctx | 'asp3',ctx proceed];
		type: #around).
		
	
	[
	aspect1 install.
	aspect2 install.
	aspect3 install.
	self assert: ((PhMockClass new) test = 'asp3asp1asp2')] ensure: [
		aspect1 uninstall.
		aspect2 uninstall.
		aspect3 uninstall].  
]

{ #category : #precedence }
PhAspectTests >> testPrecedenceBefore [
	|pc aspect1 aspect2 aspect3 |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#receiver).
	aspect1 := PhMockAspect1 new 
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver test: ('asp1', context receiver testString)];
			type: #before);
		precedence: #('PhMockAspect3' 'PhMockAspect1' 'PhMockAspect2').
	aspect2 := PhMockAspect2 new add: (PhAdvice new
		pointcut: pc;
		advice: [:context | context receiver test: ('asp2', context receiver testString)];
		type: #before).
	aspect3 := PhMockAspect3 new add: (PhAdvice new
		pointcut: pc;
		advice: [:context | context receiver test: ('asp3', context receiver testString)];
		type: #before).
	
	  
	[
	aspect1 install.
	aspect2 install.
	aspect3 install.
	self assert: ((PhMockClass new) test = 'asp2asp1asp3test')] ensure: [
		aspect1 uninstall.
		aspect2 uninstall.
		aspect3 uninstall].  
]

{ #category : #precedence }
PhAspectTests >> testPrecedenceMultiRule [
	|pc aspect1 aspect2 aspect3 |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#proceed).  
	aspect1 := PhMockAspect1 new 
		add: (PhAdvice new
			pointcut: pc;
			advice: [:ctx | 'asp1', ctx proceed];
			type: #around);
		precedence: #('PhMockAspect3' 'PhMockAspect1').
	aspect2 := PhMockAspect2 new 
		add: (PhAdvice new
			pointcut: pc;
			advice: [:ctx | 'asp2'];
			type: #around);
		precedence: #('PhMockAspect1' 'PhMockAspect2').
	aspect3 := PhMockAspect3 new 
		add: (PhAdvice new
			pointcut: pc;
			advice: [:ctx | 'asp3',ctx proceed];
			type: #around);
		precedence: #('PhMockAspect3' 'PhMockAspect2').
	
	[
	aspect1 install.
	aspect2 install.
	aspect3 install.
	self assert: ((PhMockClass new) test = 'asp3asp1asp2')] ensure: [
		aspect1 uninstall.
		aspect2 uninstall.
		aspect3 uninstall].  
]
