Class {
	#name : #CflowPointcut,
	#superclass : #PhPointcut,
	#instVars : [
		'cflowDef'
	],
	#category : 'Phantom-Core'
}

{ #category : #'as yet unclassified' }
CflowPointcut class >> newWith: aPhPointcut cflowDef: aPhPointcutDef [
	^(self new)
		selectors: aPhPointcut selectors;
		receivers: aPhPointcut receivers;
		pointcut: aPhPointcut pointcut;
		selectIfMatch: aPhPointcut selectIfMatch;
		context: aPhPointcut context;
		precedence: aPhPointcut precedence;
		override: aPhPointcut override;
		selectorsMessage: aPhPointcut selectorsMessage;  
		restrictToPackages: aPhPointcut packageRestriction;
		if: aPhPointcut ifBlock;
		inCflowOf: aPhPointcutDef;
		yourself. 
]

{ #category : #'as yet unclassified' }
CflowPointcut >> createPointcutList [
	| aSet classes receiversParser selectorsParser |
	self memoizedpc isNil
		ifFalse: [ ^ self memoizedpc ].
	aSet := Set new.
	receiversParser := self parseReceivers: self receivers.
	selectorsParser := self parseSelectors: self selectors.
	self getClassList
		do: [ :each | aSet addAll: (self pointcutsThatMatchOf: each receiversParser: receiversParser selectorsParser: selectorsParser) ].
	self memoizedpc: aSet.
	^ aSet
]

{ #category : #'as yet unclassified' }
CflowPointcut >> inCflowOf: aPointcut [
	inCflowOf := aPointcut.
]

{ #category : #'as yet unclassified' }
CflowPointcut >> isActiveOnCflowOf: aPhMethodWrapper [
	| res |
	res := (inCflowOf getActivePointcutsOnCflowOf: aPhMethodWrapper)
		anySatisfy: [ :pc | aPhMethodWrapper getCallStack includes: pc ].
	self selectIfMatch
		ifFalse: [ res := res not ].
	self pointcut notNil
		ifTrue: [ 
			self composition = #intersection:
				ifTrue: [ ^ (res & (self pointcut isActiveOnCflowOf: aPhMethodWrapper)) ]
				ifFalse: [ ^ (res | (self pointcut isActiveOnCflowOf: aPhMethodWrapper)) ] ]
		ifFalse: [
			^ res].
]

{ #category : #'as yet unclassified' }
CflowPointcut >> localIncludes: aSelector on: aClass [
		(self mayInclude: aClass)
			ifTrue: [
				| selectorParser |
				selectorParser := self parseSelectors: self selectors.
				 ^ selectorParser matches: aSelector asString]
			ifFalse: [^false]
]

{ #category : #'as yet unclassified' }
CflowPointcut >> mayInclude: aClass [
	(self
		packageRestrictionIncludes: aClass)
		ifTrue: [ 
			| classParser |
			classParser := self parseReceivers: self receivers.
			^ (classParser matches: aClass definition) ]
		ifFalse: [ ^ false ]
]

{ #category : #'as yet unclassified' }
CflowPointcut >> not [
	^ (self copy)
		selectIfMatch: self selectIfMatch not;
		yourself
]

{ #category : #'as yet unclassified' }
CflowPointcut >> notInCflowOf: aPointcut [
	inCflowOf := aPointcut.
	self not.
]
