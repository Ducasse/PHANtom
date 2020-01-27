Class {
	#name : #PhObjectDeployedMembraneTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'as yet unclassified' }
PhObjectDeployedMembraneTests >> tearDown [
	super tearDown.
	SmalltalkImage current garbageCollect.
]

{ #category : #'as yet unclassified' }
PhObjectDeployedMembraneTests >> testBlockObjectDeployedMembrane [
"	| mock block membrane membrane2 asp |
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhMockClass';
				selectors: 'test');
			advice: ['foo'];
			type: #around).
	membrane := PhMembrane new.
	membrane2 := PhMembrane new advise: membrane.
	asp registerOn:  membrane2.
	mock := PhMockClass new.
	block := [mock test].
	membrane deployOn:  block.
	self assert: (mock test = 'test').
	self assert: (block value = 'foo')."
]

{ #category : #'as yet unclassified' }
PhObjectDeployedMembraneTests >> testObjectDeployedMembrane [
	| mock1 mock2 membrane asp |
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhMockClass';
				selectors: 'test');
			advice: [:ctx | 'foo'];
			type: #around).
	membrane := PhMembrane new.
	asp registerOn:  membrane.
	mock1 := PhMockClass new.
	mock2 := PhMockClass new.
	membrane deployOn: mock1.
	self deny: (mock1 test = 'foo').
	self assert: (mock2 test = 'test').
]

{ #category : #'as yet unclassified' }
PhObjectDeployedMembraneTests >> testObjectDeployedMembrane2 [
	| mock1 mock2 membrane membrane2 asp |
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhMockClass';
				selectors: 'test');
			advice: [:ctx | 'foo'];
			type: #around).
	membrane := PhMembrane new.
	membrane2 := PhMembrane new advise: membrane.
	asp registerOn:  membrane2.
	mock1 := PhMockMockClass new.
	mock2 := PhMockClass new.
	membrane deployOn: mock1.
	self assert: (mock1 callTestMock = 'foo').
	self assert: (mock2 test = 'test').
	self assert: (PhMockMockClass new callTestMock = 'test')
]

{ #category : #'as yet unclassified' }
PhObjectDeployedMembraneTests >> testObjectDeployedMembrane3 [
	| mock1 mock2 membrane asp aspMembrane |
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhMockClass';
				selectors: 'test');
			advice: [:ctx | 'foo'];
			type: #around).
	membrane := PhMembrane new.
	aspMembrane := PhMembrane new advise: membrane.
	asp registerOn:  aspMembrane.
	mock1 := PhMockClass new.
	mock2 := PhMockClass new.
	membrane deployOn: mock1.
	self assert: (mock1 test = 'foo').
	self assert: (mock2 test = 'test').
]
