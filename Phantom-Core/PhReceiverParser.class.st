"
this class is responsable to parse the receivers declared on a pointcut.
"
Class {
	#name : #PhReceiverParser,
	#superclass : #PPCompositeParser,
	#instVars : [
		'starToken',
		'nameToken',
		'plusToken',
		'idToken',
		'metaToken',
		'allToken'
	],
	#classInstVars : [
		'classAndSubclassAction',
		'subclassesAction',
		'metaNameAction',
		'nameAction'
	],
	#category : 'Phantom-Core'
}

{ #category : #tokens }
PhReceiverParser >> allToken [
	^ starToken ==> [:node | #word asParser star]
]

{ #category : #'class parser generation' }
PhReceiverParser >> generateReceiverClassParser: aParserNode [
	| aNameParser classParser |
	aNameParser := aParserNode at: 1.
	classParser := #word asParser plus, (#space asParser plus), (('subclass:' asParser) / ('variableByteSubclass:' asParser) / ('variableSubclass:' asParser) / ('variableWordSubclass:' asParser) / ('weakSubclass:' asParser) ), (#space asParser plus), $# asParser, aNameParser, (#blank asParser | #newline asParser).
	"subclassParser := aNameParser, #space asParser plus, 'subclass:' asParser."
	(aParserNode at: 3) notNil
		ifTrue: [ | matchedClasses subclassParser |
			matchedClasses := (SmalltalkImage current allClasses) select: [:each |
				classParser matches: each definition].
			matchedClasses do: [:each |
				each allSubclasses do: [:s | classParser := classParser / s definition asParser]].
			^classParser]
		ifFalse: [^classParser]
	
]

{ #category : #'class parser generation' }
PhReceiverParser >> generateReceiverMetaclassParser: aParserNode [
	| aNameParser metaclassParser |
	aNameParser := aParserNode at: 1.
	metaclassParser := aNameParser , #space asParser plus , 'class' asParser , (#blank asParser | #newline asParser).
	(aParserNode at: 3) notNil
		ifFalse: [ ^ metaclassParser ]
		ifTrue: [ 
			| matchedMetaclasses |
			matchedMetaclasses := SmalltalkImage current allClasses
				collect: [ :each | each class ]
				thenSelect: [ :each | metaclassParser matches: each definition ].
			matchedMetaclasses
				do: [ :each | each allSubclasses do: [ :s | metaclassParser := metaclassParser / s definition asParser ] ].
			^ metaclassParser ]
]

{ #category : #'class parser generation' }
PhReceiverParser >> generateReceiverParser: aParseNode [
	^ (aParseNode at: 2) notNil
		ifTrue: [ self generateReceiverMetaclassParser: aParseNode ]
		ifFalse: [ self generateReceiverClassParser: aParseNode ]
]

{ #category : #'as yet unclassified' }
PhReceiverParser >> idToken [
	^ starToken optional, nameToken, starToken optional ==> [:node |
		| pp |
		pp := (node at: 2) asParser.
		(node at: 1) notNil ifTrue: [pp := (#word asParser starGreedy: pp), pp].
		(node at: 3) notNil ifTrue: [pp := pp, #word asParser star].
		pp]
]

{ #category : #'as yet unclassified' }
PhReceiverParser >> metaToken [
	^' class' asParser
]

{ #category : #tokens }
PhReceiverParser >> nameToken [
	^(#letter asParser, #word asParser plus) flatten.
]

{ #category : #tokens }
PhReceiverParser >> plusToken [
	^$+ asParser
]

{ #category : #tokens }
PhReceiverParser >> starToken [
	^$* asParser
]

{ #category : #parser }
PhReceiverParser >> start [
	^ ((idToken / allToken), metaToken optional , plusToken optional) end ==> [ :node | self generateReceiverParser: node ]
]
