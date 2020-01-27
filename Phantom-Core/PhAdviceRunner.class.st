Class {
	#name : #PhAdviceRunner,
	#superclass : #Object,
	#instVars : [
		'advice',
		'index',
		'type',
		'selector',
		'receiver',
		'arguments',
		'adviceGroup',
		'previousMembraneSet',
		'previousObjectDeployedMembraneSet'
	],
	#category : 'Phantom-Core'
}

{ #category : #'as yet unclassified' }
PhAdviceRunner >> addMembranes [
	"self adviceGroup wrapper setActiveMembranes: (WeakSet withAll: (self adviceGroup advisingMembranes))."
	self adviceGroup wrapper setActiveMembranes: previousMembraneSet.
	self adviceGroup wrapper setObjectDeployedActiveMembranes:  previousObjectDeployedMembraneSet. 
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> addMembranesOf: currentAdvice [
	| membraneSet objectDeployedMembraneSet |
	membraneSet := WeakSet new.
	objectDeployedMembraneSet := WeakSet new.
	membraneSet
		addAll: (self adviceGroup advisingMembranes select: [ :mbr | mbr registeredAspects includes: currentAdvice owner ]).
	objectDeployedMembraneSet
		addAll: (self adviceGroup objectDeployedAdvisingMembranes select: [:mbr | mbr registeredAspects includes: currentAdvice owner] ).
	self adviceGroup wrapper setActiveMembranes: membraneSet.
	self adviceGroup wrapper setObjectDeployedActiveMembranes:  objectDeployedMembraneSet.
]

{ #category : #accessing }
PhAdviceRunner >> advice [
	^ advice
]

{ #category : #accessing }
PhAdviceRunner >> advice: anObject [
	advice := anObject
]

{ #category : #accessing }
PhAdviceRunner >> adviceGroup [
	^ adviceGroup
]

{ #category : #accessing }
PhAdviceRunner >> adviceGroup: anObject [
	adviceGroup := anObject
]

{ #category : #accessing }
PhAdviceRunner >> arguments [
	^ arguments
]

{ #category : #accessing }
PhAdviceRunner >> arguments: anObject [
	arguments := anObject
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> buildAdviceGroupFor: aContext [
	self adviceGroup buildAdviceGroupFor: aContext.
	aContext adviceRunner: self.      
]

{ #category : #private }
PhAdviceRunner >> buildContextFor: anAdvice [
	| aContext contextExp buildAdviceContext |
	anAdvice pointcut context isEmpty
		& anAdvice pointcut dynamicContextBlock isNil
		ifTrue: [ ^ nil ].
	contextExp := anAdvice pointcut context
		collect: [ :each | 
			each = #proceed
				ifTrue: [ #method ]
				ifFalse: [ each ] ].
	buildAdviceContext := contextExp includes: #advice.
	aContext := PhContext new.
	buildAdviceContext
		ifTrue: [ contextExp := contextExp select: [ :each | (each = #advice) not ].
			self buildAdviceGroupFor: aContext ].
	contextExp
		do: [ :each | 
			aContext
				perform: (each asString , ':') asSymbol
				with: (self perform: each asSymbol) ].
	(contextExp includes: #method)
		ifTrue: [ aContext arguments: self arguments.
			aContext receiver: self receiver.
			aContext selector: self selector ].
	anAdvice pointcut dynamicContextBlock
		ifNotNil: [ :block | block value: aContext value: thisContext ].
	aContext adviceRunner: self.
	^ aContext
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> changeAdvice: anAdviceCollection continueAt: anIndex [
	advice := anAdviceCollection.
	index := anIndex -1
]

{ #category : #accessing }
PhAdviceRunner >> index [
	^ index
]

{ #category : #accessing }
PhAdviceRunner >> index: anObject [
	index := anObject
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> initialize [
	super initialize.
	index := 1
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> method [
	^ self adviceGroup wrapper oldMethod.
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> proceed [
	(self index < self advice size)
		ifFalse: [
			self addMembranes.
			^ self method valueWithReceiver: (self receiver) arguments: (self arguments)]
		ifTrue: [^ self runNextActive]
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> proceed: changedArguments [
	self arguments: changedArguments.
	(self index < self advice size)
		ifFalse: [
			self addMembranes.
			^ self method valueWithReceiver: (self receiver) arguments: (self arguments)]
		ifTrue: [^ self runNextActive]
]

{ #category : #accessing }
PhAdviceRunner >> receiver [
	^ receiver
]

{ #category : #accessing }
PhAdviceRunner >> receiver: anObject [
	receiver := anObject
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> run [
	| result |
	previousMembraneSet := self adviceGroup wrapper class currentProcessMembraneStack.
	previousObjectDeployedMembraneSet := self adviceGroup wrapper currentObjectDeployedMembraneStack. 
	result := self runAdvice.
	self adviceGroup wrapper setActiveMembranes: previousMembraneSet.
	self adviceGroup wrapper setObjectDeployedActiveMembranes:  previousObjectDeployedMembraneSet.
	^ result
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> runAdvice [
	[ self index <= self advice size ]
		whileTrue: [ 
			| currentAdvice context |
			currentAdvice := self advice at: self index.
			self addMembranesOf: currentAdvice.
			context := (self buildContextFor: currentAdvice).
			(currentAdvice pointcut
				isActiveOnContext: context 
				receiver: (self adviceGroup wrapper wrappedClass)
				selector: selector)
				ifTrue: [currentAdvice runWithin: context].
			self index:  self index + 1 ]
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> runNextActive [
	| result ctx currentAdvice currentMembranes |
	currentMembranes := self adviceGroup wrapper currentProcessMembraneStack.
	self index:  self index + 1.
	currentAdvice := self advice at: self index.
	ctx := self buildContextFor: currentAdvice.
	self addMembranesOf: currentAdvice.
	[((self index < self advice size) & ((currentAdvice pointcut 
		isActiveOnContext: ctx 
		receiver: (self adviceGroup wrapper wrappedClass)
		selector: self selector) not))] 
		whileTrue: [
			self index: self index +1.
			currentAdvice := self advice at: self index.
			ctx := self buildContextFor: currentAdvice.
			self addMembranesOf: currentAdvice.].
	(self index <= self advice size)
		ifTrue: [ result := currentAdvice runWithin: ctx]
		ifFalse: [result := self adviceGroup oldMethod valueWithReceiver: self receiver arguments: self arguments].
	self adviceGroup wrapper setActiveMembranes: currentMembranes.
	^ result
]

{ #category : #accessing }
PhAdviceRunner >> selector [
	^ selector
]

{ #category : #accessing }
PhAdviceRunner >> selector: anObject [
	selector := anObject
]

{ #category : #'as yet unclassified' }
PhAdviceRunner >> sender [
	^ self adviceGroup wrapper currentSender.
]

{ #category : #accessing }
PhAdviceRunner >> type [
	^ self subclassResponsibility
]
