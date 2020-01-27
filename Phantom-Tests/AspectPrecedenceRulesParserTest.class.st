Class {
	#name : #AspectPrecedenceRulesParserTest,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #parse }
AspectPrecedenceRulesParserTest >> testAspectParser [
	| parser |
	parser := PhPrecedenceRulesParser new.
	self assert: (parser matches: 'AsdfAspect').
	self assert: (parser matches: '*').
	self deny: (parser matches: '*+').
	self deny: (parser matches: '+*').
	self deny: (parser matches: '+').
	self deny: (parser matches: '1Aspect').
	self deny: (parser matches: 'Asp ect').
]

{ #category : #parse }
AspectPrecedenceRulesParserTest >> testAspectPlusParser [
	| parser |
	parser := PhPrecedenceRulesParser new.
	self assert: (parser matches: 'AsdfAspect+').
	self deny: (parser matches: '+Aspect').
	self deny: (parser matches: 'Foo+Aspect').
	self deny: (parser matches: '+aspect').
	self deny: (parser matches: '+').
]

{ #category : #match }
AspectPrecedenceRulesParserTest >> testAspectPlusPrecedenceMatch [
	| parser target  set classes |
	parser := PhPrecedenceRulesParser new.
	set := parser parse: 'PhMockAspectFoo+'.
	classes := PhMockAspectFoo allSubclasses.
	target := Set new.
	target add: (AspectNode new aspect: PhMockAspectFoo).
	classes do: [:each | target add: (AspectNode new aspect: each)].
	self assert: (set = target)
]

{ #category : #parse }
AspectPrecedenceRulesParserTest >> testAspectStarParser [
	| parser |
	parser := PhPrecedenceRulesParser new.
	self assert: (parser matches: 'AsdfAspect*').
	self deny: (parser matches: 'Asp*ect')..
	self deny: (parser matches: 'Aspect *')..


]

{ #category : #parse }
AspectPrecedenceRulesParserTest >> testAspectStarPlusParser [
	| parser |
	parser := PhPrecedenceRulesParser new.
	self assert: (parser matches: 'AsdfAspect*+').
	self deny: (parser matches: 'Aspect+*')..
	self deny: (parser matches: 'Aspect *+')..
]

{ #category : #match }
AspectPrecedenceRulesParserTest >> testAspectStarPrecedenceMatch [
	| parser set target classes regex |
	regex := 'PhAspectTest.*' asRegex.
	parser := PhPrecedenceRulesParser new.
	set := parser parse: 'PhAspectTest*'.
	classes := PhAspect allSubclasses select: [:class | regex matches: class name asString].
	target := Set new.
	classes do: [:class | target add: (AspectNode new aspect: class)].
	self assert: (set = target).
]

{ #category : #parse }
AspectPrecedenceRulesParserTest >> testStarAspectParser [
	| parser |
	parser := PhPrecedenceRulesParser new.
	self assert: (parser matches: '*AsdfAspect').
	self deny: (parser matches: 'Asp*ect')..
	self deny: (parser matches: '* Aspect')..
]

{ #category : #parse }
AspectPrecedenceRulesParserTest >> testStarAspectPlusParser [
	| parser |
	parser := PhPrecedenceRulesParser new.
	self assert: (parser matches: '*AsdfAspect+').
	self deny: (parser matches: '*+Aspect')..
	self deny: (parser matches: '* Aspect +')..
]

{ #category : #match }
AspectPrecedenceRulesParserTest >> testStarAspectPrecedenceMatch [
	| parser set target classes regex |
	regex := '\w*MockAspect1' asRegex.
	parser := PhPrecedenceRulesParser new.
	set := parser parse: '*MockAspect1'.
	classes := PhAspect allSubclasses select: [:class | regex matches: class name asString].
	target := Set new.
	classes do: [:class | target add: (AspectNode new aspect: class)].
	self assert: (set = target).
]

{ #category : #parse }
AspectPrecedenceRulesParserTest >> testStarAspectStarParser [
	| parser |
	parser := PhPrecedenceRulesParser new.
	self assert: (parser matches: '*AsdfAspect*').
	self deny: (parser matches: '* Aspect *')..
	self deny: (parser matches: '*Aspect *')..
	self deny: (parser matches: '* Aspect*')..
]

{ #category : #parse }
AspectPrecedenceRulesParserTest >> testStarAspectStarPlusParser [
	| parser |
	parser := PhPrecedenceRulesParser new.
	self assert: (parser matches: '*AsdfAspect*+').
	self deny: (parser matches: '*AsdfAspect+*').
	self deny: (parser matches: '*+AsdfAspect*+').
	self deny: (parser matches: '+*AsdfAspect*+').
	self deny: (parser matches: '* Aspect *')..
	self deny: (parser matches: '*Aspect *')..
	self deny: (parser matches: '* Aspect*')..
]

{ #category : #match }
AspectPrecedenceRulesParserTest >> testStarAspectStarPrecedenceMatch [
	| parser set target classes regex |
	regex := '[\w\d]*MockAspect[\w\d]*' asRegex.
	parser := PhPrecedenceRulesParser new.
	set := parser parse: '*MockAspect*'.
	classes := PhAspect allSubclasses select: [:class | regex matches: class name asString].
	target := Set new.
	classes do: [:class | target add: (AspectNode new aspect: class)].
	self assert: (set = target).
]
