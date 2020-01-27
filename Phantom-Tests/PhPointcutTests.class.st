Class {
	#name : #PhPointcutTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'context exposure' }
PhPointcutTests >> testAfterAdvicesExposure [
	| asp adv1 adv2 adv3 pc |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'foo';
		context: #(#advice).
	
	
	
	adv1 := PhAdvice new
		pointcut: pc;
		advice: [:context | 'foo'];
		type: #after.
	adv2 := PhAdvice new
		pointcut: pc;
		advice: [:context | 'bar'];
		type: #after.
	adv3 := PhAdvice new
		pointcut: pc;
		advice: [:context | 'foobar'];
		type: #after.    
	
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context afterAdvice];
			type: #around);
		add: adv1;
		add: adv2;
		add: adv3.
	[asp install.
	
	self assert: (PhMockClass new foo includes: adv1).
	self assert: (PhMockClass new foo includes: adv2).
	self assert: (PhMockClass new foo includes: adv3).
	self assert: (PhMockClass new foo size = 3)] ensure: [asp uninstall.]
]

{ #category : #composing }
PhPointcutTests >> testAnd [
	| pc1 pc2 targetSet |
	pc1 := PhPointcut new
		receivers: 'Morph';
		selectors: 'mouseEnter:'.
		
	pc2 := PhPointcut new
		receivers: 'Morph+';
		selectors: 'mouseEnter:'.
	targetSet := Set new.
	targetSet add: (Array with: Morph with: #mouseEnter:).
	self assert: ( (pc1 & pc2) getPointcuts = targetSet )          
]

{ #category : #matching }
PhPointcutTests >> testArgumentKeywordSelectorWithMiddleStringMatch [
	| set pc |
	pc := (PhPointcut new)
		receivers: 'SequenceableCollection';
		localSelectors: '_:to:_:'.
	set := Set new.
	SequenceableCollection localSelectors
		do: [ :sel | 
			((sel isKeyword) and: [((sel findBetweenSubstrings: ':') size = 3) and: [(((sel findBetweenSubstrings: ':') at: 2) = 'to')]])
				ifTrue: [ set add: (Array with: SequenceableCollection with: sel) ] ].
	self deny: (set isEmpty).
	self assert: pc getPointcuts = set
]

{ #category : #'context exposure' }
PhPointcutTests >> testArgumentsExposure [
	| pc asp |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test:';
		context: #(#arguments).
	
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context arguments at: 1];
			type: #around).
	
	[
	asp install.
	
	self assert: ((PhMockClass new test: 'argstests') = 'argstests')] ensure: [asp uninstall].    
		
]

{ #category : #'context exposure' }
PhPointcutTests >> testAroundAdvicesExposure [
	| asp adv1 adv2 adv3 pc |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'foo';
		context: #(#advice).
	
	adv1 := PhAdvice new
			pointcut: pc;
			advice: [:context | context aroundAdvice];
			type: #around.
	adv2 :=  PhAdvice new
			pointcut: pc;
			advice: [:context | context aroundAdvice];
			type: #around.
	adv3 :=  PhAdvice new
			pointcut: pc;
			advice: [:context | context aroundAdvice];
			type: #around.
	
	asp := PhAspect new
		add: adv1;
		add: adv2;
		add: adv3.
	[asp install.
	
	self assert: (PhMockClass new foo includes: adv1).
	self assert: (PhMockClass new foo includes: adv2).
	self assert: (PhMockClass new foo includes: adv3).
	self assert: (PhMockClass new foo size = 3)] ensure: [asp uninstall.]
]

{ #category : #'context exposure' }
PhPointcutTests >> testBeforeAdvicesExposure [
	| asp adv1 adv2 adv3 pc |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'foo';
		context: #(#advice).
	
	adv1 := PhAdvice new
		pointcut: pc;
		advice: [:context | 'foo'];
		type: #before.
	adv2 := PhAdvice new
		pointcut: pc;
		advice: [:context | 'bar'];
		type: #before.
	adv3 := PhAdvice new
		pointcut: pc;
		advice: [:context | 'foobar'];
		type: #before.    
	
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context beforeAdvice];
			type: #around);
		add: adv1;
		add: adv2;
		add: adv3.
	[asp install.
	
	self assert: (PhMockClass new foo includes: adv1).
	self assert: (PhMockClass new foo includes: adv2).
	self assert: (PhMockClass new foo includes: adv3).
	self assert: (PhMockClass new foo size = 3)] ensure: [asp uninstall.]
]

{ #category : #matching }
PhPointcutTests >> testClassNameMatch [
	| pc targetSet |
	pc := PhPointcut new
		receivers: 'Morph';
		selectors: 'mouseEnter:'.
	targetSet := Set new.
	targetSet add: (Array with: Morph with: #mouseEnter:).
	self assert: (pc getPointcuts = targetSet).
]

{ #category : #matching }
PhPointcutTests >> testClassNamePlusMatch [
	| pc targetSet |
	pc := PhPointcut new
		receivers: 'Morph+';
		selectors: 'mouseEnter:'.
	targetSet := Set new.
	targetSet add: (Array with: Morph with: #mouseEnter:).
	Morph allSubclasses do: [:each |
		(each allSelectors anySatisfy: [:s | s = #mouseEnter:]) ifTrue: [
			targetSet add: (Array with: each with: #mouseEnter:)]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testClassNameStarMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: 'Morph*';
		selectors: 'mouseEnter:'.
	regex := 'Morph\w*' asRegex.
	classCol := (SmalltalkImage current allClasses) select: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: Morph with: #mouseEnter:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #mouseEnter:]) ifTrue: [
			targetSet add: (Array with: each with: #mouseEnter:)]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testClassNameStarPlusMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: 'Morph*+';
		selectors: 'mouseEnter:'.
	regex := 'Morph\w*' asRegex.
	classCol := (SmalltalkImage current allClasses) select: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: Morph with: #mouseEnter:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #mouseEnter:]) ifTrue: [
			targetSet add: (Array with: each with: #mouseEnter:)]].
	classCol do: [:each | each allSubclasses do: [:s|
			(s allSelectors anySatisfy: [:sel | sel = #mouseEnter:]) ifTrue: [
				targetSet add: (Array with: s with: #mouseEnter:)]]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testClassStarNameMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: '*Morph';
		selectors: 'mouseEnter:'.
	regex := '\w*Morph' asRegex.
	classCol := (SmalltalkImage current allClasses) select: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: Morph with: #mouseEnter:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #mouseEnter:]) ifTrue: [
			targetSet add: (Array with: each with: #mouseEnter:)]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testClassStarNamePlusMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: '*Morph+';
		selectors: 'mouseEnter:'.
	regex := '\w*Morph' asRegex.
	classCol := (SmalltalkImage current allClasses) select: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: Morph with: #mouseEnter:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #mouseEnter:]) ifTrue: [
			targetSet add: (Array with: each with: #mouseEnter:)]].
	classCol do: [:each | each allSubclasses do: [:s|
			(s allSelectors anySatisfy: [:sel | sel = #mouseEnter:]) ifTrue: [
				targetSet add: (Array with: s with: #mouseEnter:)]]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testClassStarNameStarMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: '*Morph*';
		selectors: 'mouseEnter:'.
	regex := '\w*Morph\w*' asRegex.
	classCol := (SmalltalkImage current allClasses) select: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: Morph with: #mouseEnter:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #mouseEnter:]) ifTrue: [
			targetSet add: (Array with: each with: #mouseEnter:)]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testClassStarNameStarPlusMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: '*Morph*+';
		selectors: 'mouseEnter:'.
	regex := '\w*Morph\w*' asRegex.
	classCol := (SmalltalkImage current allClasses) select: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: Morph with: #mouseEnter:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #mouseEnter:]) ifTrue: [
			targetSet add: (Array with: each with: #mouseEnter:)]].
	classCol do: [:each | each allSubclasses do: [:s|
			(s allSelectors anySatisfy: [:sel | sel = #mouseEnter:]) ifTrue: [
				targetSet add: (Array with: s with: #mouseEnter:)]]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #'context exposure' }
PhPointcutTests >> testCurrentAdvicesExposure [
	| asp adv1 adv2 adv3 pc |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'foo';
		context: #(#advice).
	
	adv1 := PhAdvice new
			pointcut: pc;
			advice: [:context | context currentAdvice];
			type: #around.
	adv2 :=  PhAdvice new
			pointcut: pc;
			advice: [:context | context currentAdvice];
			type: #around.
	adv3 :=  PhAdvice new
			pointcut: pc;
			advice: [:context | context currentAdvice];
			type: #around.
	
	asp := PhAspect new
		add: adv1;
		add: adv2;
		add: adv3.
	[asp install.
	
	self assert: (PhMockClass new foo includes: adv1).
	self assert: (PhMockClass new foo includes: adv2).
	self assert: (PhMockClass new foo includes: adv3).
	self assert: (PhMockClass new foo size = 3)] ensure: [asp uninstall.]
]

{ #category : #'custom-parser-match' }
PhPointcutTests >> testCustomParserMatch [
	| parser set pc |
	parser := (#any asParser plusGreedy: 'instanceVariableNames:' asParser) , 'instanceVariableNames:' asParser
		, (#any asParser plusGreedy: 'counter' asParser) , (#any asParser plusGreedy: 'classVariableNames:' asParser).
	pc := (PhPointcut new)
		receivers: parser;
		localSelectors: #any asParser;
		restrictToPackages: #('Phantom-Tests').
	set := Set new.
	(RPackageOrganizer default packageNamed: 'Phantom-Tests' ifAbsent: nil) classes
		do: [ :class | 
			(class instVarNames includes: 'counter')
				ifTrue: [ class localSelectors do: [ :sel | set add: (Array with: class with: sel) ] ] ].
	self assert: pc getPointcuts = set
]

{ #category : #'context exposure' }
PhPointcutTests >> testDynamicContext [
	| pc asp |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#arguments #receiver);
		dynamicContextBlock: [:contextObject :thereContext |
			| idx |
			idx := (1 to: (thereContext contextStack size)) findLast: [:index |
				((thereContext contextStack at: index) receiver) == ((thereContext contextStack at: 1) receiver)].
			contextObject dynamicContext at: #sender put: (thereContext contextStack at: (idx+5)) receiver].  

	asp := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver test: (context dynamicContext at: #sender)];
			type: #before).
	[asp install.
	
	self assert: ((PhMockClass new test) == self)] ensure: [asp uninstall].    
		
]

{ #category : #matching }
PhPointcutTests >> testGetMatchedClasses [
	| pc |
	pc := PhPointcut new
		receivers: 'PhMockAspectFoo+';
		selectors: #any asParser.
	self assert: (pc getMatchedClasses asSet = PhMockAspectFoo withAllSubclasses asSet).
]

{ #category : #matching }
PhPointcutTests >> testMetaClassNameMatch [
	| pc targetSet |
	pc := PhPointcut new
		receivers: 'Morph class';
		selectors: 'newBounds:'.
	targetSet := Set new.
	targetSet add: (Array with: (Morph class) with: #newBounds:).
	self assert: (pc getPointcuts = targetSet).
]

{ #category : #matching }
PhPointcutTests >> testMetaClassNamePlusMatch [
	| pc targetSet |
	pc := PhPointcut new
		receivers: 'Morph class+';
		selectors: 'newBounds:'.
	targetSet := Set new.
	targetSet add: (Array with: (Morph class) with: #newBounds:).
	Morph class allSubclasses do: [:each |
		(each allSelectors anySatisfy: [:s | s = #newBounds:]) ifTrue: [
			targetSet add: (Array with: each with: #newBounds:)]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testMetaClassNameStarMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: 'Morph* class';
		selectors: 'newBounds:'.
	regex := 'Morph\w* class' asRegex.
	classCol := (SmalltalkImage current allClasses) collect: [:each | each class] thenSelect: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: (Morph class) with: #newBounds:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #newBounds:]) ifTrue: [
			targetSet add: (Array with: each with: #newBounds:)]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testMetaClassNameStarPlusMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: 'Morph* class+';
		selectors: 'newBounds:'.
	regex := 'Morph\w* class' asRegex.
	classCol := (SmalltalkImage current allClasses) collect: [:each | each class] thenSelect: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: (Morph class) with: #newBounds:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #newBounds:]) ifTrue: [
			targetSet add: (Array with: each with: #newBounds:)]].
	classCol do: [:each | each allSubclasses do: [:s|
			(s allSelectors anySatisfy: [:sel | sel = #newBounds:]) ifTrue: [
				targetSet add: (Array with: s with: #newBounds:)]]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testMetaClassStarNameMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: '*Morph class';
		selectors: 'newBounds:'.
	regex := '\w*Morph class' asRegex.
	classCol := (SmalltalkImage current allClasses) collect: [:each | each class] thenSelect: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: (Morph class) with: #newBounds:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #newBounds:]) ifTrue: [
			targetSet add: (Array with: each with: #newBounds:)]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testMetaClassStarNamePlusMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: '*Morph class+';
		selectors: 'newBounds:'.
	regex := '\w*Morph class' asRegex.
	classCol := (SmalltalkImage current allClasses) collect: [:each | each class] thenSelect: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: (Morph class) with: #newBounds:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #newBounds:]) ifTrue: [
			targetSet add: (Array with: each with: #newBounds:)]].
	classCol do: [:each | each allSubclasses do: [:s|
			(s allSelectors anySatisfy: [:sel | sel = #newBounds:]) ifTrue: [
				targetSet add: (Array with: s with: #newBounds:)]]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testMetaClassStarNameStarMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: '*Morph* class';
		selectors: 'newBounds:'.
	regex := '\w*Morph\w* class' asRegex.
	classCol := (SmalltalkImage current allClasses) collect: [:each | each class] thenSelect: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: (Morph class) with: #newBounds:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #newBounds:]) ifTrue: [
			targetSet add: (Array with: each with: #newBounds:)]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #matching }
PhPointcutTests >> testMetaClassStarNameStarPlusMatch [
	| pc targetSet classCol regex |
	pc := PhPointcut new
		receivers: '*Morph* class+';
		selectors: 'newBounds:'.
	regex := '\w*Morph\w* class' asRegex.
	classCol := (SmalltalkImage current allClasses) collect: [:each | each class ] thenSelect: [:each | regex matches: each name].
	targetSet := Set new.
	targetSet add: (Array with: (Morph class) with: #newBounds:).
	classCol do: [:each |
		(each allSelectors anySatisfy: [:s | s = #newBounds:]) ifTrue: [
			targetSet add: (Array with: each with: #newBounds:)]].
	classCol do: [:each | each allSubclasses do: [:s|
			(s allSelectors anySatisfy: [:sel | sel = #newBounds:]) ifTrue: [
				targetSet add: (Array with: s with: #newBounds:)]]].
	self assert: (pc getPointcuts = targetSet).
	
]

{ #category : #'context exposure' }
PhPointcutTests >> testMethodExposure [
	| pc asp |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#proceed).
	
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context proceed];
			type: #around).
	[asp install.
	
	self assert: ((PhMockClass new test) = 'test')] ensure: [asp uninstall].    
		
]

{ #category : #composing }
PhPointcutTests >> testNot [
	| pc regex pcCol targetSet |
	pc := PhPointcut new
		receivers: '*Morph*';
		selectors: 'mouseEnter:'.
	regex := '\w*Morph\w*' asRegex.
	targetSet := Set new.
	(SmalltalkImage current allClasses) do: [:each | 
		(regex matches: each name asString) not
			ifTrue: [each allSelectors do: [:sel |
					targetSet add: (Array with: each with: sel)]] 
			ifFalse: [each allSelectors do: [:sel |
					(sel = #mouseEnter:) not
						ifTrue: [targetSet add: (Array with: each with: sel)]]].
		(regex matches: each class name asString) not
			ifTrue: [each class allSelectors do: [:sel |
					targetSet add: (Array with: (each class) with: sel)]] 
			ifFalse: [each class allSelectors do: [:sel |
					(sel = #mouseEnter:) not
						ifTrue: [targetSet add: (Array with: (each class) with: sel)]]]].
	pcCol := pc not getPointcuts.
	self assert: (pcCol = targetSet).
]

{ #category : #composing }
PhPointcutTests >> testNot2 [
	| pc pc2 regex pcCol targetSet |
	pc := PhPointcut new
		receivers: '*Morph*';
		selectors: 'mouseEnter:'.
	pc2 := PhPointcut new
		receivers: #word asParser star , ' class' asParser;
		selectors: #any asParser star.
	regex := '\w*Morph\w*' asRegex.
	targetSet := Set new.
	(RPackageOrganizer default
		packageNamed: 'Morphic-Kernel'
		ifAbsent: nil)
		ifNotNil: [ :package | 
			package classes
				do: [ :class | 
					(regex matches: class name asString) not
						ifTrue: [ class allSelectors
								do: [ :sel | targetSet add: (Array with: class with: sel) ] ]
						ifFalse: [ class allSelectors
								do: [ :sel | 
									(sel = #mouseEnter:) not
										ifTrue: [ targetSet add: (Array with: class with: sel) ] ] ] ] ].
	pcCol := (pc not & pc2 not restrictToPackages: #('Morphic-Kernel'))
		getPointcuts.
	self assert: pcCol = targetSet
]

{ #category : #composing }
PhPointcutTests >> testNot3 [
	| pc1 pc2 col1 col2 |
	pc1 := PhPointcut new
		receivers: '*Morph*';
		selectors: 'mouseEnter:'.  
	pc2 := PhPointcut new
		receivers: (#word asParser star, ' class' asParser);
		selectors: (#any asParser star).
		
	col1 := (((pc1 not) & (pc2 not)) restrictToPackages: #('Kernel' 'Morphic')) getPointcuts.
	col2 := (( (pc1 | pc2) not ) restrictToPackages: #('Kernel' 'Morphic')) getPointcuts.
	self assert: (col1 = col2)
]

{ #category : #matching }
PhPointcutTests >> testOneArgumentKeywordSelectorMatch [
	| set pc |
	pc := (PhPointcut new)
		receivers: 'PhPointcut';
		localSelectors: '_:'.
	set := Set new.
	PhPointcut localSelectors
		do: [ :sel | 
			(sel isKeyword and: [ (sel findBetweenSubstrings: ':') size = 1 ])
				ifTrue: [ set add: (Array with: PhPointcut with: sel) ] ].
	self deny: (set isEmpty).
	self assert: pc getPointcuts = set
]

{ #category : #composing }
PhPointcutTests >> testOr [
	| pc1 pc2 targetSet |
	pc1 := PhPointcut new
		receivers: 'Morph';
		selectors: 'mouseEnter:'.
	pc2 := PhPointcut new
		receivers: 'OrderedCollection';
		selectors: 'add:'.
	targetSet := Set new.
	targetSet
		add: (Array with: Morph with: #mouseEnter:);
		add: (Array with: OrderedCollection with: #add:).
	self assert: ( (pc1 | pc2) getPointcuts = targetSet )            
]

{ #category : #'package-restriction' }
PhPointcutTests >> testPackageRestriction [
	| pc target |
	pc := PhPointcut new
		receivers:
			(#any asParser starGreedy: 'class:' asParser) , 'class:' asParser
				, #any asParser star;
		selectors: 'hash';
		restrictToPackages: #('Kernel').
	target := Set new.
	(RPackageOrganizer default packageNamed: 'Kernel' ifAbsent: nil)
		ifNotNil: [ :package | 
			package classes
				do: [ :class | 
					(class isKindOf: Trait)
						ifFalse: [ (class allSelectors includes: #hash)
								ifTrue: [ target add: (Array with: class with: #hash) ] ] ] ].
	self assert: target = pc getPointcuts
]

{ #category : #'matching-arrays' }
PhPointcutTests >> testReceiverArray [
	| pc targetSet |
	pc := PhPointcut new
		receivers: (Array with: 'Morph' with: 'BorderedMorph');
		selectors: 'mouseEnter:'.
	targetSet := Set new.
	targetSet 
		add: (Array with: Morph with: #mouseEnter:);
		add: (Array with: BorderedMorph with: #mouseEnter:).
		
	self assert: (pc getPointcuts = targetSet)  
		
]

{ #category : #'context exposure' }
PhPointcutTests >> testReceiverExposure [
	| pc asp mock |
	mock := PhMockClass new.
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#receiver).
	
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context receiver];
			type: #around).
	[asp install.
	
	self assert: (mock test = mock)] ensure: [asp uninstall].    
		
]

{ #category : #'matching-arrays' }
PhPointcutTests >> testReceiverSelectorArray [
	| pc targetSet |
	pc := PhPointcut new
		receivers: (Array with: 'Morph' with: 'BorderedMorph');
		selectors: (Array with: 'mouseEnter:' with: 'mouseDown:').
	targetSet := Set new.
	targetSet 
		add: (Array with: Morph with: #mouseEnter:);
		add: (Array with: Morph with: #mouseDown:);
		add: (Array with: BorderedMorph with: #mouseEnter:);
		add: (Array with: BorderedMorph with: #mouseDown:).
		
	self assert: (pc getPointcuts = targetSet)  
		
]

{ #category : #'matching-arrays' }
PhPointcutTests >> testSelectorArray [
	| pc targetSet |
	pc := PhPointcut new
		receivers: 'Morph';
		selectors: (Array with: 'mouseEnter:' with: 'mouseDown:').
	targetSet := Set new.
	targetSet 
		add: (Array with: Morph with: #mouseEnter:);
		add: (Array with: Morph with: #mouseDown:).
		
	self assert: (pc getPointcuts = targetSet)  
		
]

{ #category : #'context exposure' }
PhPointcutTests >> testSelectorExposure [
	| pc asp |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#selector).
	
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context selector];
			type: #around).
	[asp install.
	
	self assert: ((PhMockClass new test) = #test)] ensure: [asp uninstall].    
		
]

{ #category : #'context exposure' }
PhPointcutTests >> testSenderExposure [
	| pc asp |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#sender).
	
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: pc;
			advice: [:context | context sender name asString];
			type: #around).
	[asp install.
	
	self assert: ((PhMockClass new test) = self name asString)] ensure: [asp uninstall].    
		
]

{ #category : #'context exposure' }
PhPointcutTests >> testSenderExposureFromSendTo [
	| pc asp mock |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'test';
		context: #(#sender).
	mock := PhMockClass new.
	asp := PhAspect new
		add: (PhAdvice
			around: pc
			send: #getSender: to: mock).
	[asp install.
	
	self assert: ((PhMockClass new test) = self)] ensure: [asp uninstall].    
		
]

{ #category : #matching }
PhPointcutTests >> testTwoArgumentKeywordSelectorMatch [
	| set pc |
	pc := (PhPointcut new)
		receivers: 'PhPointcut';
		localSelectors: '_:_:'.
	set := Set new.
	PhPointcut localSelectors
		do: [ :sel | 
			(sel isKeyword and: [ (sel findBetweenSubstrings: ':') size = 2 ])
				ifTrue: [ set add: (Array with: PhPointcut with: sel) ] ].
	self deny: (set isEmpty).
	self assert: pc getPointcuts = set
]

{ #category : #matching }
PhPointcutTests >> testTwoArgumentKeywordSelectorWithStringMatch [
	| set pc |
	pc := (PhPointcut new)
		receivers: 'LinkedList';
		localSelectors: 'add:_:'.
	set := Set new.
	LinkedList localSelectors
		do: [ :sel | 
			((sel isKeyword) and: [((sel findBetweenSubstrings: ':') size = 2) and: [(((sel findBetweenSubstrings: ':') at: 1) = 'add')]])
				ifTrue: [ set add: (Array with: LinkedList with: sel) ] ].
	self deny: (set isEmpty).
	self assert: pc getPointcuts = set
]

{ #category : #matching }
PhPointcutTests >> testUnarySelectorMatch [
	| set pc |
	pc := (PhPointcut new)
		receivers: 'PhPointcut';
		localSelectors: '_'.
	set := Set new.
	PhPointcut localSelectors
		do: [ :sel | 
			sel isUnary
				ifTrue: [ set add: (Array with: PhPointcut with: sel) ] ].
	self deny: (set isEmpty).
	self assert: pc getPointcuts = set
]
