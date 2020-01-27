Class {
	#name : #PhAdviceGroup,
	#superclass : #Object,
	#instVars : [
		'beforeAdvice',
		'aroundAdvice',
		'afterAdvice',
		'currentAdviceIndex',
		'wrapper',
		'advisingMembranes',
		'objectDeployedAdvisingMembranes',
		'adviceCollection'
	],
	#category : 'Phantom-Core'
}

{ #category : #'as yet unclassified' }
PhAdviceGroup >> adviceCollection: anAdviceCollection [
	adviceCollection := anAdviceCollection.
	beforeAdvice := (anAdviceCollection select: [:adv | adv type = #before]) asArray.
	aroundAdvice := (anAdviceCollection select: [:adv | adv type = #around]) asArray.
	afterAdvice := (anAdviceCollection select: [:adv | adv type = #after]) asArray reversed.
]

{ #category : #'as yet unclassified' }
PhAdviceGroup >> advisingMembranes [
	^ advisingMembranes
]

{ #category : #'as yet unclassified' }
PhAdviceGroup >> advisingMembranes: aMembraneSet [
	advisingMembranes := aMembraneSet
]

{ #category : #accessing }
PhAdviceGroup >> afterAdvice [
	^ afterAdvice
]

{ #category : #accessing }
PhAdviceGroup >> afterAdvice: anAdviceCollection [
	afterAdvice := anAdviceCollection.
	afterAdvice do: [:each | each type: #after]
]

{ #category : #accessing }
PhAdviceGroup >> aroundAdvice [
	^ aroundAdvice
]

{ #category : #accessing }
PhAdviceGroup >> aroundAdvice: anAdviceCollection [
	aroundAdvice := anAdviceCollection.
	aroundAdvice do: [:each | each type: #around]
]

{ #category : #accessing }
PhAdviceGroup >> beforeAdvice [
	^ beforeAdvice
]

{ #category : #accessing }
PhAdviceGroup >> beforeAdvice: anAdviceCollection [
	beforeAdvice := anAdviceCollection.
	beforeAdvice do: [:each | each type: #before]
]

{ #category : #private }
PhAdviceGroup >> buildAdviceGroupFor: aContext [
	aContext adviceDictionary at: #before put: self beforeAdvice.
	aContext adviceDictionary at: #after put: self afterAdvice.
	aContext adviceDictionary at: #around put: self aroundAdvice.
]

{ #category : #'as yet unclassified' }
PhAdviceGroup >> objectDeployedAdvisingMembranes [
	^ objectDeployedAdvisingMembranes
]

{ #category : #'as yet unclassified' }
PhAdviceGroup >> objectDeployedAdvisingMembranes: membraneArray [
	objectDeployedAdvisingMembranes := membraneArray
]

{ #category : #accessing }
PhAdviceGroup >> oldMethod [
	^ self wrapper oldMethod
]

{ #category : #'as yet unclassified' }
PhAdviceGroup >> run: aSelector with: arguments in: aReceiver [
	| aResult |
	PhBeforeAdviceRunner new
		selector: aSelector;
		receiver: aReceiver;
		arguments: arguments;
		adviceGroup: self;
		advice: self beforeAdvice;
		run.
	aResult := PhAroundAdviceRunner new
		selector: aSelector;
		receiver: aReceiver;
		arguments: arguments;
		adviceGroup: self;
		advice: self aroundAdvice;
		run.
	PhAfterAdviceRunner new
		selector: aSelector;
		receiver: aReceiver;
		arguments: arguments;
		adviceGroup: self;
		advice: self afterAdvice;
		run.
	^aResult
]

{ #category : #accessing }
PhAdviceGroup >> wrapper [
	^wrapper
]

{ #category : #accessing }
PhAdviceGroup >> wrapper: aPhMethodMethodWrapper [
	wrapper := aPhMethodMethodWrapper
]
