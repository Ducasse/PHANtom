Class {
	#name : #PhAspectWeaverTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'as yet unclassified' }
PhAspectWeaverTests >> testInstalledAspects [
	| asp |
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhMockClass';
				selectors: 'foo');
			advice: [:ctx | 'foo'];
			type: #around).
	[asp install.
	self assert: (PhAspectWeaver installedAspects includes: asp)] ensure: [
	asp uninstall.
	self deny: (PhAspectWeaver installedAspects includes: asp)]
]

{ #category : #'as yet unclassified' }
PhAspectWeaverTests >> testInstalledMembranes [
	| membrane |
	membrane := PhMembrane new
		pointcut: (PhPointcut new
			receivers: 'PhMockClass';
			selectors: 'foo').
	[membrane install.
	self assert: (PhAspectWeaver installedMembranes includes: membrane)] ensure: [
	membrane uninstall.
	self deny: (PhAspectWeaver installedMembranes includes: membrane)]
]

{ #category : #'as yet unclassified' }
PhAspectWeaverTests >> testMembraneMethodWrapperDictionary [
	| membrane wrappers targetClass targetSelectors |
	membrane := PhMembrane new
		pointcut:
			(PhPointcut new
				receivers: 'PhMockClass';
				selectors: #('foo' 'test' 'bar')).
	[membrane install.
	wrappers := PhAspectWeaver classVarNamed: 'WrapperList'.
	self assert: wrappers size = 3.
	self assert: (wrappers includesKey: (Array with: PhMockClass with: #foo)).
	self assert: (wrappers includesKey: (Array with: PhMockClass with: #test)).
	self assert: (wrappers includesKey: (Array with: PhMockClass with: #bar)) ] ensure: [ membrane uninstall ]
]

{ #category : #'as yet unclassified' }
PhAspectWeaverTests >> testMethodWrapperDictionary [
	| asp wrappers targetClass targetSelectors |
	
	"asp := PhAspect new.
	asp add: (PhAdvice new
				advice: [:context | 'foo'];
				pointcut: (PhPointcut new
					receivers: 'PhMockClass';
					selectors: 'foo');
				type: #before).
				
	 asp add: (PhAdvice new
				advice: [:context | 'foo'];
				pointcut: (PhPointcut new
					receivers: 'PhMockClass';
					selectors: 'test');
				type: #before).
	
	 asp add: (PhAdvice new
				advice: [:context | 'foo'];
				pointcut: (PhPointcut new
					receivers: 'PhMockClass';
					selectors: 'bar');
				type: #before).
				
	asp install.
	[wrappers := PhAspectWeaver classVarNamed: 'WrapperList'.
	self assert: (wrappers size = 3).
	self assert: (wrappers includesKey: (Array with: PhMockClass with: #foo)).
	self assert: (wrappers includesKey: (Array with: PhMockClass with: #test)).
	self assert: (wrappers includesKey: (Array with: PhMockClass with: #bar)).
	] ensure: [asp uninstall]"
]

{ #category : #'as yet unclassified' }
PhAspectWeaverTests >> testMethodWrapperGeneration [
"	| asp wrappers targetClass targetSelectors |
	
	asp := PhAspect new.
	asp add: (PhAdvice new
				advice: [:context | 'foo'];
				pointcut: (PhPointcut new
					receivers: 'PhMockClass';
					selectors: 'foo');
				type: #before).
				
	 asp add: (PhAdvice new
				advice: [:context | 'foo'];
				pointcut: (PhPointcut new
					receivers: 'PhMockClass';
					selectors: 'test');
				type: #before).
	
	 asp add: (PhAdvice new
				advice: [:context | 'foo'];
				pointcut: (PhPointcut new
					receivers: 'PhMockClass';
					selectors: 'bar');
				type: #before).
				
	asp install.
	[wrappers := PhAspectWeaver classVarNamed: 'WrapperList'.
	self assert: ((wrappers at: (Array with: PhMockClass with: #foo)) reference classSymbol = #PhMockClass).
	self assert: ((wrappers at: (Array with: PhMockClass with: #test)) reference classSymbol = #PhMockClass).
	self assert: ((wrappers at: (Array with: PhMockClass with: #bar)) reference classSymbol = #PhMockClass).
	self assert: ((wrappers at: (Array with: PhMockClass with: #foo)) reference methodSymbol = #foo).
	self assert: ((wrappers at: (Array with: PhMockClass with: #test)) reference methodSymbol = #test).
	self assert: ((wrappers at: (Array with: PhMockClass with: #bar)) reference methodSymbol = #bar).
	] ensure: [asp uninstall]"
]
