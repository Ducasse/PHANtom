Class {
	#name : #PhAfterAdviceRunner,
	#superclass : #PhAdviceRunner,
	#category : 'Phantom-Core'
}

{ #category : #'as yet unclassified' }
PhAfterAdviceRunner >> changeAdvice: anAdviceCollection continueAt: anIndex [
	super changeAdvice: anAdviceCollection continueAt: anIndex.
	self adviceGroup afterAdvice: anAdviceCollection.
]

{ #category : #'as yet unclassified' }
PhAfterAdviceRunner >> type [
	^#after
]
