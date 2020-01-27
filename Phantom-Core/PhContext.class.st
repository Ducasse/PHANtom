"
This class is used to pass the context of execution to the advices on aspects
"
Class {
	#name : #PhContext,
	#superclass : #Object,
	#instVars : [
		'receiver',
		'arguments',
		'selector',
		'method',
		'sender',
		'dynamicContext',
		'adviceDictionary',
		'adviceRunner'
	],
	#category : 'Phantom-Core'
}

{ #category : #accessing }
PhContext >> adviceDictionary [
	^adviceDictionary 
]

{ #category : #accessing }
PhContext >> adviceRunner [
	^adviceRunner
]

{ #category : #accessing }
PhContext >> adviceRunner: anAdviceRunner [
	adviceRunner := anAdviceRunner
]

{ #category : #advices }
PhContext >> afterAdvice [
	^ adviceDictionary at: #after
]

{ #category : #advices }
PhContext >> afterAdvice: adviceCollection [
	self adviceDictionary at: #after put: adviceCollection asArray.
	self adviceRunner adviceGroup afterAdvice: (self adviceDictionary at: #after)
]

{ #category : #accessing }
PhContext >> arguments [
	^ arguments
]

{ #category : #accessing }
PhContext >> arguments: anObject [
	arguments := anObject
]

{ #category : #advices }
PhContext >> aroundAdvice [
	^ self adviceDictionary at: #around
]

{ #category : #advices }
PhContext >> aroundAdvice: adviceCollection [
	self adviceDictionary at: #around put: adviceCollection asArray.
	self adviceRunner adviceGroup aroundAdvice: (self adviceDictionary at: #around)  
]

{ #category : #advices }
PhContext >> beforeAdvice [
	^ self adviceDictionary at: #before
]

{ #category : #advices }
PhContext >> beforeAdvice: adviceCollection [
	self adviceDictionary at: #before put: adviceCollection asArray.
	self adviceRunner adviceGroup beforeAdvice: (self adviceDictionary at: #before)  
]

{ #category : #advices }
PhContext >> currentAdvice [
	^ self adviceDictionary at: (self adviceRunner type)
]

{ #category : #advices }
PhContext >> currentAdvice: anAdviceCollection continueAt: anIndex [
	self adviceDictionary at: (self adviceRunner type) put: anAdviceCollection asArray.
	"wrapper perform: ((currentAdviceGroup, 'Advice:') asSymbol) with: (adviceDictionary at: currentAdviceGroup).
	wrapper currentAdviceIndex: (anIndex -1)"
	self adviceRunner changeAdvice: anAdviceCollection continueAt: anIndex.
]

{ #category : #advices }
PhContext >> currentAdviceIndex [
	^adviceRunner index.
]

{ #category : #accessing }
PhContext >> dynamicContext [
	^dynamicContext
]

{ #category : #'initialize-release' }
PhContext >> initialize [
	super initialize.
	dynamicContext := Dictionary new.
	adviceDictionary := Dictionary	newFrom: {
		#before -> nil.
		#after -> nil.
		#around -> nil}
]

{ #category : #accessing }
PhContext >> method [
	^ method
]

{ #category : #accessing }
PhContext >> method: anObject [
	method := anObject
]

{ #category : #proceed }
PhContext >> proceed [
	^ self adviceRunner proceed.  
]

{ #category : #proceed }
PhContext >> proceed: args [
	^ self adviceRunner proceed: args.  
]

{ #category : #accessing }
PhContext >> receiver [
	^ receiver
]

{ #category : #accessing }
PhContext >> receiver: anObject [
	receiver := anObject
]

{ #category : #accessing }
PhContext >> selector [
	^ selector
]

{ #category : #accessing }
PhContext >> selector: anObject [
	selector := anObject
]

{ #category : #accessing }
PhContext >> sender [
	^ sender
]

{ #category : #accessing }
PhContext >> sender: aSender [
	sender := aSender
]
