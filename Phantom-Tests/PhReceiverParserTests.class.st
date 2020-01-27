Class {
	#name : #PhReceiverParserTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #matchTests }
PhReceiverParserTests >> testClassMatch [
	| targetCol generatedCol parser |
	targetCol := Set new.
	targetCol add: Morph.
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: 'Morph'.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	self assert: (generatedCol = targetCol)
]

{ #category : #matchMetaTests }
PhReceiverParserTests >> testClassMetaMatch [
	| targetCol generatedCol parser |
	targetCol := Set new.
	targetCol add: Morph class.
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: 'Morph class'.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	self assert: (generatedCol = targetCol)
]

{ #category : #matchMetaTests }
PhReceiverParserTests >> testClassMetaPlusMatch [
	| targetCol generatedCol parser |
	targetCol := Set new.
	targetCol
		add: Morph class;
		addAll: (Morph class allSubclasses).  
	
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: 'Morph class+'.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	self assert: (generatedCol = targetCol)
]

{ #category : #tests }
PhReceiverParserTests >> testClassMetaStarMatch [

	| targetCol generatedCol parser |
	
	targetCol := Set new.
	targetCol addAll: Class allSubclasses.
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: '* class'.
	
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	
	self assertCollection: generatedCol equals: targetCol 
]

{ #category : #parserTests }
PhReceiverParserTests >> testClassName [
	| parser |
	parser := PhReceiverParser new.
	self assert: (parser matches: 'Morph').
	self assert: (parser matches: 'Morph class').
	self deny: (parser matches: '1Morph').
	self deny: (parser matches: ' Morph').
	self deny: (parser matches: 'Mor ph').
	self deny: (parser matches: 'Morph foo').
	
]

{ #category : #parserTests }
PhReceiverParserTests >> testClassNameMetaPlus [
	| parser |
	parser := PhReceiverParser new.
	self assert: (parser matches: 'Morph class+').
	self assert: (parser matches: '*Morph class+').
	self assert: (parser matches: '*Morph* class+').
	self assert: (parser matches: 'Morph* class+').
	self deny: (parser matches: '*Morph+ class').
	self deny: (parser matches: '*Morph+* class').
	self deny: (parser matches: 'Morph*+ class').
]

{ #category : #parserTests }
PhReceiverParserTests >> testClassNameMetaStar [
	| parser |
	parser := PhReceiverParser new.
	self assert: (parser matches: '*Morph class').
	self assert: (parser matches: '*Morph* class').
	self assert: (parser matches: 'Morph* class').
	self deny: (parser matches: '*Morph class*').
	self deny: (parser matches: 'Morph class*').

	
]

{ #category : #parserTests }
PhReceiverParserTests >> testClassNamePlus [
	| parser |
	parser := PhReceiverParser new.
	self assert: (parser matches: 'Morph+').
	self assert: (parser matches: '*Morph*+').
	self assert: (parser matches: 'Morph*+').
	self assert: (parser matches: '*Morph+').
	self deny: (parser matches: '*Morph +').
	self deny: (parser matches: '*Morph+*').
	self deny: (parser matches: 'Morph+*').
]

{ #category : #parserTests }
PhReceiverParserTests >> testClassNameStar [
	| parser |
	parser := PhReceiverParser new.
	self assert: (parser matches: '*Morph').
	self assert: (parser matches: '*Morph*').
	self assert: (parser matches: 'Morph*').
	self deny: (parser matches: '*Morph *').
	self deny: (parser matches: '* Morph *').
	
]

{ #category : #matchTests }
PhReceiverParserTests >> testClassPlusMatch [
	| targetCol generatedCol parser |
	targetCol := Set new.
	targetCol
		add: Morph;
		addAll: (Morph allSubclasses).  
	
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: 'Morph+'.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	self assert: (generatedCol = targetCol)
]

{ #category : #matchTests }
PhReceiverParserTests >> testClassStarMatch [
	| targetCol generatedCol parser regex |
	regex := 'Morph\w*' asRegex.
	targetCol := Set new.
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: 'Morph*'.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(regex matches: each name asString) ifTrue: [targetCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	self assert: (generatedCol = targetCol)
]

{ #category : #matchMetaTests }
PhReceiverParserTests >> testClassStarMetaMatch [
	| targetCol generatedCol parser regex |
	targetCol := Set new.
	targetCol add: Morph class.
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: 'Morph* class'.
	regex := 'Morph\w* class' asRegex.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class].
		(regex matches: each class name asString) ifTrue: [targetCol add: each class]].
	self assert: (generatedCol = targetCol)
]

{ #category : #matchMetaTests }
PhReceiverParserTests >> testClassStarMetaPlusMatch [
	| targetCol generatedCol parser regex tmp |
	targetCol := Set new.
	targetCol add: Morph class.
	generatedCol := Set new.
	tmp := Set new.
	parser := (PhReceiverParser new) parse: 'Morph* class+'.
	regex := 'Morph\w* class' asRegex.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class].
		(regex matches: each class name asString) ifTrue: [targetCol add: each class]].
	targetCol do: [:each | tmp addAll: each allSubclasses].
	targetCol addAll: tmp.  
	self assert: (generatedCol = targetCol)
]

{ #category : #matchTests }
PhReceiverParserTests >> testClassStarPlusMatch [
	| targetCol generatedCol parser regex tmp |
	regex := 'Morph\w*' asRegex.
	targetCol := Set new.
	generatedCol := Set new.
	tmp := Set new.
	parser := (PhReceiverParser new) parse: 'Morph*+'.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(regex matches: each name asString) ifTrue: [targetCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	targetCol do: [:each | tmp addAll: each allSubclasses ].
	targetCol addAll: tmp.  
	self assert: (generatedCol = targetCol)
]

{ #category : #matchTests }
PhReceiverParserTests >> testStarClassMatch [
	| targetCol generatedCol parser regex |
	regex := '\w*Morph' asRegex.
	targetCol := Set new.
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: '*Morph'.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(regex matches: each name asString) ifTrue: [targetCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	self assert: (generatedCol = targetCol)
]

{ #category : #matchMetaTests }
PhReceiverParserTests >> testStarClassMetaMatch [
	| targetCol generatedCol parser regex |
	targetCol := Set new.
	targetCol add: Morph class.
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: '*Morph class'.
	regex := '\w*Morph class' asRegex.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class].
		(regex matches: each class name asString) ifTrue: [targetCol add: each class]].
	self assert: (generatedCol = targetCol)
]

{ #category : #matchMetaTests }
PhReceiverParserTests >> testStarClassMetaPlusMatch [
	| targetCol generatedCol parser regex tmp |
	targetCol := Set new.
	targetCol add: Morph class.
	generatedCol := Set new.
	tmp := Set new.
	parser := (PhReceiverParser new) parse: '*Morph class+'.
	regex := '\w*Morph class' asRegex.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class].
		(regex matches: each class name asString) ifTrue: [targetCol add: each class]].
	targetCol do: [:each | tmp addAll: each allSubclasses].
	targetCol addAll: tmp.
	self assert: (generatedCol = targetCol)
]

{ #category : #matchTests }
PhReceiverParserTests >> testStarClassPlusMatch [
	| targetCol generatedCol parser regex tmp |
	regex := '\w*Morph' asRegex.
	targetCol := Set new.
	generatedCol := Set new.
	tmp := Set new.
	parser := (PhReceiverParser new) parse: '*Morph+'.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(regex matches: each name asString) ifTrue: [targetCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	targetCol do: [:each | tmp addAll: each allSubclasses ].
	targetCol addAll: tmp.  
	self assert: (generatedCol = targetCol)
]

{ #category : #matchTests }
PhReceiverParserTests >> testStarClassStarMatch [
	| targetCol generatedCol parser regex |
	regex := '\w*Morph\w*' asRegex.
	targetCol := Set new.
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: '*Morph*'.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(regex matches: each name asString) ifTrue: [targetCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	self assert: (generatedCol = targetCol)
]

{ #category : #matchMetaTests }
PhReceiverParserTests >> testStarClassStarMetaMatch [
	| targetCol generatedCol parser regex |
	targetCol := Set new.
	targetCol add: Morph class.
	generatedCol := Set new.
	parser := (PhReceiverParser new) parse: '*Morph* class'.
	regex := '\w*Morph\w* class' asRegex.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class].
		(regex matches: each class name asString) ifTrue: [targetCol add: each class]].
	self assert: (generatedCol = targetCol)
]

{ #category : #matchMetaTests }
PhReceiverParserTests >> testStarClassStarMetaPlusMatch [
	| targetCol generatedCol parser regex tmp |
	targetCol := Set new.
	targetCol add: Morph class.
	generatedCol := Set new.
	tmp := Set new.
	parser := (PhReceiverParser new) parse: '*Morph* class+'.
	regex := '\w*Morph\w* class' asRegex.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class].
		(regex matches: each class name asString) ifTrue: [targetCol add: each class]].
	targetCol do: [:each | tmp addAll: each allSubclasses ].
	targetCol addAll: tmp.  
	self assert: (generatedCol = targetCol)
]

{ #category : #matchTests }
PhReceiverParserTests >> testStarClassStarPlusMatch [
	| targetCol generatedCol parser regex tmp |
	regex := '\w*Morph\w*' asRegex.
	targetCol := Set new.
	generatedCol := Set new.
	tmp := Set new.
	parser := (PhReceiverParser new) parse: '*Morph*+'.
	SmalltalkImage current allClasses do: [:each |
		(parser matches: each definition) ifTrue: [generatedCol add: each].
		(regex matches: each name asString) ifTrue: [targetCol add: each].
		(parser matches: each class definition) ifTrue: [generatedCol add: each class]].
	targetCol do: [:each | tmp addAll: each allSubclasses ].
	targetCol addAll: tmp.    
	self assert: (generatedCol = targetCol)
]
