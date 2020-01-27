"
PhAspect represent an Aspect, it has a collection of PhAdvices, an PhClassModifiers.
Use add: to add advices.
Use addClassModifier: to add a classModifier.
Use precedence: to specify the desired precedence on the installed aspects.
Use install to install it, and uninstall to uninstall the aspect.
Example:
	PhAspect new
		add: (PhAdvice new ...);
		addClassMofifier: (PhClassModifier new on: ...);
		precedence: 'PhAspectBigger+ PhAspectFoo'.
"
Class {
	#name : #PhAspect,
	#superclass : #Object,
	#instVars : [
		'adviceCollection',
		'precedence',
		'classModifiers',
		'installed',
		'onMembranes',
		'membrane',
		'aspectMembrane',
		'sarasa'
	],
	#category : 'Phantom-Core'
}

{ #category : #accessing }
PhAspect >> add: anAdvice [
	anAdvice owner: self.
	self adviceCollection add: anAdvice.
	"PhAspectWeaver cleanCache."
]

{ #category : #accessing }
PhAspect >> addClassModifier: aClassModifier [
	self classModifiers add: aClassModifier.
]

{ #category : #private }
PhAspect >> adviceCollection [
	^ adviceCollection
]

{ #category : #accessing }
PhAspect >> aspectMembrane [
	^ aspectMembrane
]

{ #category : #private }
PhAspect >> classModifiers [
	^ classModifiers 
]

{ #category : #private }
PhAspect >> getPointcuts [
	| pcs |
	pcs := Set new.
	self adviceCollection do: [:adv |
		pcs addAll: adv pointcut getPointcuts].
	^ pcs
]

{ #category : #private }
PhAspect >> includes: aMethod on: aClass [
	self adviceCollection do: [ :adv | 
		(adv pointcut includes: aMethod on: aClass)
			ifTrue: [^true] ].
	^ false
]

{ #category : #initialization }
PhAspect >> initialize [
	adviceCollection := OrderedCollection new.
	classModifiers := Set new.
	installed := false.
	onMembranes := Set new.
]

{ #category : #'install-uninstall' }
PhAspect >> install [
	membrane := PhMembrane new pointcut: self.
	aspectMembrane := PhMembrane new advise: membrane.
	self registerOn: aspectMembrane.
	membrane install.  
	"| pointcutSet pointcut |
	pointcutSet := Set new.
	self adviceCollection do: [:each |
		pointcutSet add: each pointcut].
	pointcutSet isEmpty ifFalse: [
		(pointcutSet size < 2) 
			ifTrue: [pointcut := pointcutSet asArray at: 1]
			ifFalse: [
				pointcut := pointcutSet asArray reduce: [:a :b |
					a por: b]]].
	membrane := PhMembrane new pointcut: pointcut.
	membrane install.
	self registerOn: membrane."
]

{ #category : #'install-uninstall' }
PhAspect >> installClassModification [
	installed ifFalse: [
		self classModifiers do: [:each | each install].
		installed := true]
]

{ #category : #private }
PhAspect >> mayInclude: aClass [
	self adviceCollection do: [ :adv | 
		(adv pointcut mayInclude: aClass)
			ifTrue: [^true] ].
	^ false
]

{ #category : #private }
PhAspect >> onMembranes [
	^ onMembranes
]

{ #category : #private }
PhAspect >> onMembranes: anObject [
	onMembranes := anObject
]

{ #category : #accessing }
PhAspect >> precedence [
	^ precedence ifNil: [precedence := #()]  
]

{ #category : #accessing }
PhAspect >> precedence: aPrecedenceArray [
	precedence := aPrecedenceArray
]

{ #category : #'install-uninstall' }
PhAspect >> registerOn: aMembrane [
	aMembrane registerAspect: self.
	self onMembranes add: aMembrane.
	self installClassModification.
]

{ #category : #accessing }
PhAspect >> remove: anAdvice [
	self adviceCollection remove: anAdvice.
	"PhAspectWeaver cleanCache"
]

{ #category : #accessing }
PhAspect >> removeClassModifier: aClassModifier [
	self classModifiers remove: aClassModifier
]

{ #category : #'install-uninstall' }
PhAspect >> uninstall [
	self unregisterFrom: aspectMembrane.
	membrane uninstall.
]

{ #category : #'install-uninstall' }
PhAspect >> uninstallClassModification [
	"PhAspectWeaver unInstall: self"
	installed ifTrue: [
		self classModifiers do: [:each | each uninstall].
		installed := false]
]

{ #category : #'install-uninstall' }
PhAspect >> unregisterFrom: aMembrane [
	aMembrane unregisterAspect: self.
	self onMembranes remove: aMembrane ifAbsent: nil.
	self onMembranes isEmpty ifTrue: [self uninstallClassModification]
]
