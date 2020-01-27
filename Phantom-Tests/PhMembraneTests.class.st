Class {
	#name : #PhMembraneTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'as yet unclassified' }
PhMembraneTests >> testAdvisedMembrane [
	| membrane1 membrane2  asp1 asp2 pc |
	[pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test'.
	membrane1 := PhMembrane new.
	asp1 := PhAspect new
		add: (PhAdvice new
			advice: [:ctx | Transcript show: (PhMockClass new test); cr];
			pointcut: pc;
			type: #after).
	asp1 registerOn: membrane1.
	membrane2 := PhMembrane new advise: membrane1.
	asp2 := PhAspect new
		add: (PhAdvice new
			advice: [:ctx | Transcript show: 'Advised'; cr];
			pointcut: pc;
			type: #after).
	asp2 registerOn: membrane2.
	membrane1 install. 
	self assert: (PhMockClass new test = 'test').
	] ensure: [
	membrane1 uninstall]
]

{ #category : #'as yet unclassified' }
PhMembraneTests >> testMembraneVisibility [
	| asp membrane aspectMembrane pc1 pc2 |
	pc1 := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test'.
	pc2 := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'testString'.
	
	membrane := PhMembrane new pointcut: pc1.
	aspectMembrane := PhMembrane new advise: membrane.
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: (pc1 | pc2);
			advice: [:ctx | 'foo'];
			type: #around).
	[asp registerOn: aspectMembrane.
	membrane install.
	self assert: (PhMockClass new test = 'foo').
	self deny: (PhMockClass new testString = 'foo').
	self assert: (PhMockClass new testString = 'test')] ensure: [membrane uninstall]    
]

{ #category : #tests }
PhMembraneTests >> testReentrancy [

	| membrane asp pc |
	[pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test'.
	membrane := PhMembrane new.
	asp := PhAspect new
		add: (PhAdvice new
			advice: [:ctx | Transcript open; show: (PhMockClass new test); cr];
			pointcut: pc;
			type: #after).
	asp registerOn: membrane.
	membrane install.
	self assert: (PhMockClass new test = 'test').
	] ensure: [membrane uninstall.]
]
