Class {
	#name : #PhBeforeAdviceRunner,
	#superclass : #PhAdviceRunner,
	#category : 'Phantom-Core'
}

{ #category : #'as yet unclassified' }
PhBeforeAdviceRunner >> changeAdvice: anAdviceCollection continueAt:  anIndex [
	super changeAdvice: anAdviceCollection continueAt: anIndex.
	self adviceGroup afterAdvice: anAdviceCollection.
]

{ #category : #'as yet unclassified' }
PhBeforeAdviceRunner >> type [
	^#before
]
