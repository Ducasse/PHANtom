Class {
	#name : #PhSelectorParserTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testAnyMatch [
	| parser |
	parser := (PhSelectorParser new) parse: '_'.
	self assert: (parser matches: 'bar').
	self assert: (parser matches: 'foobar').
	self deny: (parser matches: 'foobar:').
	self deny: (parser matches: 'foo:bla:hh:bar:').
	self deny: (parser matches: 'foo:bar:').
	self deny: (parser matches: 'bla:foo:hh:bar:').
	self deny: (parser matches: 'bar:').
	
	  
	
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testAnyMultiwordMatch [
	| parser |
	parser := (PhSelectorParser new) parse: '_:bar:'.
	self assert: (parser matches: 'any:bar:').
	self assert: (parser matches: 'foo:bar:').
	self deny: (parser matches: 'foo:bla:hh:bar:').
	self deny: (parser matches: 'bla:foo:hh:bar:').
	self deny: (parser matches: 'bar:').
	
	  
	
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testAnyWithArgsMatch [
	| parser |
	parser := (PhSelectorParser new) parse: '_:'.
	self assert: (parser matches: 'bar:').
	self assert: (parser matches: 'foobar:').
	self deny: (parser matches: 'foobar').
	self deny: (parser matches: 'foo:bla:hh:bar:').
	self deny: (parser matches: 'foo:bar:').
	self deny: (parser matches: 'bla:foo:hh:bar:').
	
	  
	
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testBinary [
	| parser |
	parser := PhSelectorParser new.
	self assert: (parser matches: '*').
	self assert: (parser matches: '***').
	self assert: (parser matches: '==>').
	self assert: (parser matches: '/').
	self deny: (parser matches: '_/').
	self deny: (parser matches: '_/:').
	self deny: (parser matches: '+:').
	self deny: (parser matches: '/_').
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testBinaryMatch [
	| parser |
	parser := (PhSelectorParser new) parse: '*'.
	self assert: (parser matches: '*').
	self deny: (parser matches: '**').
	self deny: (parser matches: '***').
	self deny: (parser matches: '=>').
	self deny: (parser matches: 'foo').
	self deny: (parser matches: 'foo:').
	
	
	
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testMultiword [
	| parser |
	parser := PhSelectorParser new.
	self assert: (parser matches: 'foo:').
	self assert: (parser matches: 'foo:bar:').
	self assert: (parser matches: 'foo:bar:foobar:').
	self deny: (parser matches: '1foo:').
	self deny: (parser matches: 'foo:bar').
	self deny: (parser matches: 'foo:+bar:').
	
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testMultiwordAny [
	| parser |
	parser := PhSelectorParser new.
	self assert: (parser matches: '_:foo:').
	self assert: (parser matches: '_').
	self assert: (parser matches: '_:').
	self assert: (parser matches: 'foo:_:').
	self assert: (parser matches: '_:foo:_:_:bar:').
	self deny: (parser matches: '_foo:_:bar:_:').
	self deny: (parser matches: '_:foo').
	self deny: (parser matches: 'foo_:').
	self deny: (parser matches: '_foo').
	self deny: (parser matches: 'foo:_:bar').
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testMultiwordAnyMatch [
	| parser |
	parser := (PhSelectorParser new) parse: 'bar:_:'.
	self assert: (parser matches: 'bar:foo:').
	self assert: (parser matches: 'bar:bla:').
	self deny: (parser matches: 'foo:bla:hh:bar:').
	self deny: (parser matches: 'foo:bar:').
	self deny: (parser matches: 'bla:foo:hh:bar:').
	self deny: (parser matches: 'bar:').
	
	  
	
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testMultiwordAnyMultiwordMatch [
	| parser |
	parser := (PhSelectorParser new) parse: 'foo:_:bar:'.
	self assert: (parser matches: 'foo:any:bar:').
	self assert: (parser matches: 'foo:bla:bar:').
	self deny: (parser matches: 'foo:bla:hh:bar:').
	self deny: (parser matches: 'foo:bar:').
	self deny: (parser matches: 'bla:foo:hh:bar:').
	
	  
	
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testMultiwordMatch [
	| parser |
	parser := (PhSelectorParser new) parse: 'foo:'.
	self assert: (parser matches: 'foo:').
	self deny: (parser matches: 'foo').
	self deny: (parser matches: 'foo:bar:').
	self deny: (parser matches: 'foo:bar:foobar:').
	
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testUnary [
	| parser |
	parser := PhSelectorParser new.
	self assert: (parser matches: 'foo').
	self deny: (parser matches: '1foo').
	self deny: (parser matches: '_:foo').
	self deny: (parser matches: '#foo').
	self deny: (parser matches: '*foo').
]

{ #category : #'as yet unclassified' }
PhSelectorParserTests >> testUnaryMatch [
	| parser |
	parser := (PhSelectorParser new) parse: 'foo'.
	self assert: (parser matches: 'foo').
	self deny: (parser matches: 'foobar').
	self deny: (parser matches: 'foo:').
	self deny: (parser matches: 'bar').
	self deny: (parser matches: '*').
]
