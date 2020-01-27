"
This class is responsable to parse the precedence rules defined on a pointcut or aspect.
"
Class {
	#name : #PhPrecedenceRulesParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'letter',
		'word',
		'any',
		'identifier',
		'anysubclass',
		'identifierStar',
		'starIdentifierStar',
		'starAny'
	],
	#category : 'Phantom-Core'
}

{ #category : #tokens }
PhPrecedenceRulesParser >> any [
	^ $* asParser
]

{ #category : #tokens }
PhPrecedenceRulesParser >> anysubclass [
	^$+ asParser
]

{ #category : #'node set generation' }
PhPrecedenceRulesParser >> buildNodeSetFrom: aParserNode [
	| aSet |
	aSet := Set new.
	((aParserNode at: 1) matches: (PhAspect name asString)) ifTrue: [aSet add: PhAspect].
	PhAspect allSubclasses do: [:asp |
		((aParserNode at: 1) matches: (asp name asString)) ifTrue: [aSet add: asp]].
	(aParserNode at: 2) notNil ifTrue: [
		| subs |
		subs := Set new.
		aSet do: [:asp | asp allSubclasses do: [:sub | subs add: sub]].
		subs do: [:asp | aSet add: asp.]].
	^aSet collect: [:asp | AspectNode new aspect: asp].
]

{ #category : #tokens }
PhPrecedenceRulesParser >> identifier [
	^ (letter, word star) flatten
]

{ #category : #tokens }
PhPrecedenceRulesParser >> identifierStar [
	^ (identifier, any optional, anysubclass optional) ==> [:node |
		| precedenceParser|
		precedenceParser := (node at: 1) asParser.
		(node at: 2) notNil ifTrue: [precedenceParser := precedenceParser, #word asParser star].
		Array with: precedenceParser with: (node at: 3)]
]

{ #category : #tokens }
PhPrecedenceRulesParser >> letter [
	^ #letter asParser
]

{ #category : #tokens }
PhPrecedenceRulesParser >> starAny [
	^ (any) ==> [:node | Array with: (#word asParser star) with: nil]
]

{ #category : #tokens }
PhPrecedenceRulesParser >> starIdentifierStar [
	^ (any, word plus flatten, any optional, anysubclass optional) ==> [:node |
		| precedeceParser |
		precedeceParser := (#word asParser starGreedy: ((node at: 2) asParser)), (node at: 2) asParser.
		(node at: 3) notNil ifTrue: [precedeceParser := precedeceParser, #word asParser star].
		Array with: precedeceParser with: (node at: 4)]
]

{ #category : #parser }
PhPrecedenceRulesParser >> start [
	^ (identifierStar / starIdentifierStar / starAny) end ==> [:node | self buildNodeSetFrom: node  ]
]

{ #category : #tokens }
PhPrecedenceRulesParser >> word [
	^ #word asParser
]
