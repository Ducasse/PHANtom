"
this class is responsable to parse the selectors declared on a pointcut.
"
Class {
	#name : #PhSelectorParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'identifier',
		'keyword',
		'unary',
		'binary',
		'multiword',
		'anyKeyUnary',
		'anyKeyMulti'
	],
	#category : 'Phantom-Core'
}

{ #category : #tokens }
PhSelectorParser >> anyKeyMulti [
	^($_ asParser, $: asParser) ==> [:node | self identifier, $: asParser].
]

{ #category : #tokens }
PhSelectorParser >> anyKeyUnary [
	^($_ asParser, $: asParser not) ==> [:node | self identifier].
]

{ #category : #tokens }
PhSelectorParser >> binary [
	^ ((PPPredicateObjectParser anyOf: '!%&*+,-/<=>?@\|~') ,
	  (PPPredicateObjectParser anyOf: '!%&*+,/<=>?@\|~') star) flatten token ==> [:node | node inputValue asParser]
]

{ #category : #tokens }
PhSelectorParser >> identifier [
	^ #letter asParser, #word asParser star
]

{ #category : #tokens }
PhSelectorParser >> keyword [
	^ (identifier , $: asParser) token ==> [:node | node inputValue asParser].
]

{ #category : #tokens }
PhSelectorParser >> multiword [
	^ (keyword | anyKeyMulti) plus
]

{ #category : #parser }
PhSelectorParser >> start [
	^ (unary / anyKeyUnary  / binary / multiword) end ==> [:node |
		(node isCollection) 
			ifTrue: [
				(node size > 1) 
					ifTrue:  [| p |
						p := node reduce: [:a :b | a,b].
						p end] 
					ifFalse: [(node at: 1) end]  ]
			ifFalse: [node end] ]
]

{ #category : #tokens }
PhSelectorParser >> unary [
	^ (identifier, $: asParser not) token ==> [:node | node inputValue asParser]
]
