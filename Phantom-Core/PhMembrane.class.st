Class {
	#name : #PhMembrane,
	#superclass : #Object,
	#instVars : [
		'advisedMembranes',
		'pointcut',
		'registeredAspects',
		'advisingMembranes'
	],
	#category : 'Phantom-Core'
}

{ #category : #public }
PhMembrane >> advise: aMembrane [
	self advisedMembranes add: aMembrane.
	aMembrane advisingMembranes add: self.
	PhAspectWeaver updateMembranes.
	"self advisedMembranes do: [:each | each advisingMembranes add: self]"
]

{ #category : #accessing }
PhMembrane >> advisedMembranes [
	^ advisedMembranes ifNil: [advisedMembranes := Set new]
]

{ #category : #accessing }
PhMembrane >> advisedMembranes: aMembraneSet [
	advisedMembranes := aMembraneSet
]

{ #category : #accessing }
PhMembrane >> advisingMembranes [
	^ advisingMembranes ifNil: [advisingMembranes := Set new.]
]

{ #category : #public }
PhMembrane >> deployOn: anObject [
	PhAspectWeaver deploy: self on: anObject.
]

{ #category : #finalization }
PhMembrane >> finalize [
	PhAspectWeaver updateMembranes.
]

{ #category : #public }
PhMembrane >> install [
	PhAspectWeaver installMembrane: self.
	"self advisedMembranes do: [:each | each advisingMembranes add: self]"
]

{ #category : #testing }
PhMembrane >> isBaseMembrane [
	^ self advisedMembranes isEmpty  
]

{ #category : #accessing }
PhMembrane >> pointcut [
	^ pointcut
]

{ #category : #accessing }
PhMembrane >> pointcut: aPhPointcut [
	pointcut := aPhPointcut
]

{ #category : #public }
PhMembrane >> registerAspect: anAspect [
	self registeredAspects add: anAspect.
	anAspect onMembranes add: self.
	PhAspectWeaver updateMembranes.
]

{ #category : #accessing }
PhMembrane >> registeredAspects [
	^ registeredAspects ifNil: [registeredAspects := Set new]
]

{ #category : #public }
PhMembrane >> unAdvise: aMembrane [
	self advisedMembranes remove: aMembrane.
	aMembrane advisingMembranes remove: self.
]

{ #category : #public }
PhMembrane >> undeployFrom: anObject [
	PhAspectWeaver undeploy: self from: anObject
]

{ #category : #public }
PhMembrane >> uninstall [
	PhAspectWeaver uninstallMembrane: self.
	"self registeredAspects do: [:each | each unregisterFrom: self]".
	"self advisedMembranes do: [:each | each advisingMembranes remove: self ifAbsent: nil]"
]

{ #category : #public }
PhMembrane >> unregisterAspect: anAspect [
	self registeredAspects remove: anAspect ifAbsent: nil.
	anAspect onMembranes remove: self ifAbsent: nil.
	
	"self flag: 'I dont understand why I need to flush memoization caches here --JF'."
	"PhAspectWeaver flushPointcutsMemo.
	PhPointcut resetMemoizedcd."
	
	PhAspectWeaver updateMembranes.
]
