Class {
	#name : #PhMethodWrapper,
	#superclass : #ObjectAsMethodWrapper,
	#instVars : [
		'needCleanUp'
	],
	#category : 'Phantom-Core'
}

{ #category : #private }
PhMethodWrapper >> currentSender [
	| stack |
	stack := thisContext stack.
	"stack explore."
	(1 to: stack size)
		do: [ :idx | 
			(stack at: idx) receiver == self & ((stack at: idx) selector == #run:with:in:)
				ifTrue: [ 
					((stack at: idx + 1) receiver isKindOf: PhMethodWrapper) & ((stack at: idx + 1) selector == #doesNotUnderstand:)
						ifTrue: [ ^ (stack at: idx + 2) receiver ]
						ifFalse: [ ^ (stack at: idx + 1) receiver ] ] ].
	self error: 'sender not found'
]

{ #category : #'install-uninstall' }
PhMethodWrapper >> initialize [
	super initialize.
	needCleanUp := false.
]

{ #category : #'install-uninstall' }
PhMethodWrapper >> install [
	self wrappedClass ifNil: [^self].
	(self wrappedClass localSelectors includes: self selector) 
		ifTrue: [	needCleanUp := false.]
		ifFalse: [needCleanUp := true].
	"super install."
	oldMethod := self wrappedClass lookupSelector: self selector.
	[oldMethod isKindOf: self class] whileTrue: [oldMethod := oldMethod oldMethod].
	self wrappedClass methodDict at: self selector put: self
]

{ #category : #accessing }
PhMethodWrapper >> needCleanUp [
	^ needCleanUp
]

{ #category : #accessing }
PhMethodWrapper >> needCleanUp: anObject [
	needCleanUp := anObject
]

{ #category : #'install-uninstall' }
PhMethodWrapper >> uninstall [
	self wrappedClass ifNil: [^self].
	super uninstall.
	self needCleanUp ifTrue: [
		SystemAnnouncer  uniqueInstance suspendAllWhile: [self wrappedClass removeSelector: self selector]]
]
