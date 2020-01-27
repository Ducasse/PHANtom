"
This class is responsable to weave the aspects into the system.
"
Class {
	#name : #PhAspectWeaver,
	#superclass : #Object,
	#classVars : [
		'InstalledMembranes',
		'ObjectInstalledMembranes',
		'UpdateEnabled',
		'WrapperList'
	],
	#category : 'Phantom-Core'
}

{ #category : #'initialize-release' }
PhAspectWeaver class >> activateSystemNotification [
	"SystemChangeNotifier uniqueInstance
		notify: self
		ofSystemChangesOfItem: #class
		change: #Added
		using: #verifyNewClass:."
	SystemAnnouncer uniqueInstance
		subscribe: ClassAdded
		send: #verifyNewClass:
		to: self.
		
	"SystemChangeNotifier uniqueInstance
		notify: self
		ofSystemChangesOfItem: #class
		change: #Modified
		using: #systemEvent:."
	SystemAnnouncer uniqueInstance
		subscribe: ClassModifiedClassDefinition
		send: #systemEvent:
		to: self.
	
	"SystemChangeNotifier uniqueInstance
		notify: self
		ofSystemChangesOfItem: #class
		change: #Removed
		using: #systemEvent:."
	SystemAnnouncer uniqueInstance
		subscribe: ClassRemoved
		send: #systemEvent:
		to: self.	
	
	"SystemChangeNotifier uniqueInstance
		notify: self
		ofSystemChangesOfItem: #class
		change: #Renamed
		using: #classRename:."
	SystemAnnouncer uniqueInstance
		subscribe: ClassRenamed
		send: #classRename:
		to: self.	
	
	"SystemChangeNotifier uniqueInstance
		notify: self
		ofSystemChangesOfItem: #method
		change: #Added
		using: #verifyNewMethod:."
	SystemAnnouncer uniqueInstance
		subscribe: MethodAdded
		send: #verifyNewMethod:
		to: self.	
	
	"SystemChangeNotifier uniqueInstance
		notify: self
		ofSystemChangesOfItem: #method
		change: #Modified
		using: #methodModification:."
	SystemAnnouncer uniqueInstance
		subscribe: MethodModified
		send: #methodModification:
		to: self.	
		
	"SystemChangeNotifier uniqueInstance
		notify: self
		ofSystemChangesOfItem: #method
		change: #Removed
		using: #methodRemoved:"
	SystemAnnouncer uniqueInstance
		subscribe: MethodRemoved
		send: #methodRemoved:
		to: self.
]

{ #category : #private }
PhAspectWeaver class >> addAllAdvisingMembranesOf: aMembrane to: aSet [
	(aSet includes: aMembrane) 
		ifTrue: [^self]
		ifFalse: [
			aSet add: aMembrane.
			aMembrane advisingMembranes do: [:mbr |
				self addAllAdvisingMembranesOf: mbr to: aSet]] 
]

{ #category : #accessors }
PhAspectWeaver class >> addMembrane: aMembrane [
	self installedMembranes add: aMembrane.. 
]

{ #category : #'as yet unclassified' }
PhAspectWeaver class >> addObjectDeployedMembranesPointcutsTo: aPointcutDict [
	| membranes allMembranes cfPointcuts |
	membranes := Set new.
	allMembranes := Set new.
	cfPointcuts := OrderedCollection new.
	self objectMembranes keysDo: [:obj |
		((obj class allSelectors) difference: (ProtoObject allSelectors))
			do: [:each |
				cfPointcuts add: (Array with: (obj class) with: each)]].
	self objectMembranes do: [ :each | membranes addAll: each ].
	membranes do: [ :mbr | self addAllAdvisingMembranesOf: mbr to: allMembranes ].
	allMembranes
		do: [ :membrane | 
			(self getMembranePointcuts: membrane)
				do: [ :pointcut | aPointcutDict at: pointcut ifAbsent: [ aPointcutDict at: pointcut put: #() ] ] ].
	cfPointcuts do: [:pc | aPointcutDict at: pc ifAbsent: [aPointcutDict at: pc put: #()]].
	^ aPointcutDict
]

{ #category : #notification }
PhAspectWeaver class >> classRename: anEvent [
	anEvent classRenamed methodDict do: [:each |
		(each isKindOf: PhMethodWrapper)
			ifTrue: [
				each reference setClass: (anEvent classRenamed) methodSymbol: (each reference methodSymbol)]].
	self update.
]

{ #category : #private }
PhAspectWeaver class >> cleanWrappers [
	WrapperList notEmpty 
		ifTrue: [
			WrapperList do: [:each | each uninstall ].
			WrapperList removeAll].
]

{ #category : #private }
PhAspectWeaver class >> combineOrderOf: aSortedAdvicesCollection and: anotherSortedAdviceCollection [
	| combinedCollection rest |
	combinedCollection := OrderedCollection new.
	rest := OrderedCollection new.
	combinedCollection addAll: aSortedAdvicesCollection.
	anotherSortedAdviceCollection reverseDo: [:each |
		(combinedCollection includes: each) 
			ifTrue: [	rest do: [:adv | combinedCollection add: adv after: each]. rest removeAll]
			ifFalse: [rest addFirst: each]].
	combinedCollection addAllFirst: rest.
	^combinedCollection  
]

{ #category : #private }
PhAspectWeaver class >> compileAndInstallMembranes [
	| pointcutDict aspectRulesDict membranes |
	pointcutDict := Dictionary new.
	membranes := Set new.
	self installedMembranes do: [: mbr |
		self addAllAdvisingMembranesOf: mbr to: membranes].
	membranes do: [:membrane |
		(self getMembranePointcuts: membrane) do: [:pointcut |
			pointcutDict at: pointcut
				ifPresent: [:membraneCollection |
					(membraneCollection includes: membrane) ifFalse: [membraneCollection add: membrane]]
				ifAbsent: [pointcutDict at: pointcut put: (OrderedCollection with: membrane)]]].
	self addObjectDeployedMembranesPointcutsTo: pointcutDict.
	WrapperList := self getMembraneWrapperListWith: pointcutDict.
	WrapperList do: [:each | each install]
]

{ #category : #'as yet unclassified' }
PhAspectWeaver class >> deploy: aMembrane on: anObject [
	self objectMembranes at: anObject
		ifPresent: [:col | col add: aMembrane]
		ifAbsent: [
			self objectMembranes at: anObject put: (Set with: aMembrane)].
	WeakRegistry default add: anObject executor: aMembrane.
	self updateMembranes.
]

{ #category : #update }
PhAspectWeaver class >> flushPointcutsMemo [
	"This could be optimised so that we dont need to do an allInstances"
	PhPointcut allInstances do: [:pc| 
		pc memoizedpc: nil.
		pc resetParsers].

]

{ #category : #update }
PhAspectWeaver class >> flushPointcutsParser [
	"This could be optimised so that we dont need to do an allInstances"
	PhPointcut allInstances do: [:pc| pc resetParsers].

]

{ #category : #private }
PhAspectWeaver class >> getMembranePointcuts: aMembrane [
	aMembrane pointcut
		ifNotNil: [ :pc | ^ pc getPointcuts ]
		ifNil: [ "aMembrane pointcut
		ifNotNilDo: [ :pc | ^ pc getPointcuts ]
		ifNil: [ 
			aMembrane advisedMembranes
				ifNil: [ ^ #() ]
				ifNotNil: [ 
					| pcSet |
					pcSet := Set new.
					aMembrane registeredAspects
						do: [ :asp | asp adviceCollection do: [ :adv | pcSet addAll: adv pointcut getPointcuts ] ].
					^ pcSet ] ]"
			| pcSet |
			pcSet := Set new.
			aMembrane registeredAspects
				do: [ :asp | 
					asp adviceCollection
						do: [ :adv | pcSet addAll: adv pointcut getPointcuts ] ].
			^ pcSet ]
]

{ #category : #private }
PhAspectWeaver class >> getMembraneWrapperListWith: aPointcutDictionary [
	| dict |
	dict := Dictionary new.
	aPointcutDictionary keysAndValuesDo: [:key :value |
		dict at: key put: (PhMembraneMethodWrapper on: (key at: 1) selector: (key at: 2) with: value asArray)].
	^dict  
]

{ #category : #private }
PhAspectWeaver class >> includes: aMethod on: aClass [
	|  membranes objectMembranes |
	
	membranes := Set new.
	objectMembranes := Set new.
	self installedMembranes do: [: mbr |
		self addAllAdvisingMembranesOf: mbr to: membranes].
	self objectMembranes do: [ :each | objectMembranes addAll: each ].
	objectMembranes do: [ :mbr | self addAllAdvisingMembranesOf: mbr to: membranes ].
	membranes do: [:membrane |
		(self method: aMethod on: aClass isIncludedOn: membrane)
			ifTrue: [^true] ].
	^ false
]

{ #category : #'initialize-release' }
PhAspectWeaver class >> initialize [
	super initialize.
	self activateSystemNotification.
	WrapperList := Dictionary new.
]

{ #category : #'install/uninstall' }
PhAspectWeaver class >> installMembrane: aMembrane [
	self cleanWrappers.
	self addMembrane: aMembrane.
	self compileAndInstallMembranes
]

{ #category : #accessors }
PhAspectWeaver class >> installedAspects [
	| aspectSet allMembranes |
	aspectSet := Set new.
	allMembranes := Set new.
	InstalledMembranes do: [:mbr | self addAllAdvisingMembranesOf: mbr to: allMembranes].
	allMembranes do: [:e | 
		aspectSet addAll: e registeredAspects].
	^ aspectSet.
]

{ #category : #accessors }
PhAspectWeaver class >> installedMembranes [
	^ InstalledMembranes ifNil: [InstalledMembranes := Set new.]
]

{ #category : #private }
PhAspectWeaver class >> mayInclude: aClass [
	|  membranes objectMembranes |
	
	membranes := Set new.
	objectMembranes := Set new.
	self installedMembranes do: [: mbr |
		self addAllAdvisingMembranesOf: mbr to: membranes].
	self objectMembranes do: [ :each | objectMembranes addAll: each ].
	objectMembranes do: [ :mbr | self addAllAdvisingMembranesOf: mbr to: membranes ].
	membranes do: [:membrane |
		(self membrane: membrane mayInclude: aClass)
			ifTrue: [^true] ].
	^ false
]

{ #category : #private }
PhAspectWeaver class >> membrane: aMembrane mayInclude: aClass [
	aMembrane pointcut
		ifNotNil: [ :pc | ^ pc mayInclude: aClass ]
		ifNil: [ aMembrane registeredAspects
				do: [ :asp | 
					asp adviceCollection
						do: [ :adv | 
							(adv pointcut mayInclude: aClass)
								ifTrue: [ ^ true ] ].
					asp classModifiers
						do: [ :cm | 
							(cm pointcut mayInclude: aClass)
								ifTrue: [ ^ true ] ] ].
			^ false ]
]

{ #category : #private }
PhAspectWeaver class >> method: aMethod on: aClass isIncludedOn: aMembrane [
	aMembrane pointcut
		ifNotNil: [ :pc | ^ pc includes: aMethod on: aClass ]
		ifNil: [ aMembrane registeredAspects
				do: [ :asp | 
					asp adviceCollection
						do: [ :adv | 
							(adv pointcut includes: aMethod on: aClass)
								ifTrue: [ ^ true ] ].
					asp classModifiers
						do: [ :cm | 
							(cm pointcut includes: aMethod on: aClass)
								ifTrue: [ ^ true ] ] ].
			^ false ]
]

{ #category : #notification }
PhAspectWeaver class >> methodModification: anEvent [
	(anEvent oldMethod isKindOf: PhMethodWrapper)
		ifTrue: [ 
			anEvent oldMethod oldMethod: anEvent newMethod.
			anEvent oldMethod needCleanUp: false.
			anEvent oldMethod install ]
]

{ #category : #notification }
PhAspectWeaver class >> methodRemoved: anEvent [
	(anEvent methodRemoved isKindOf: PhMethodWrapper)
		ifTrue: [ WrapperList removeKey: (Array with: anEvent methodClass with: anEvent selector) ].
	self updateEnabled
		ifTrue: [ 
			self flushPointcutsMemo.
			self updateMembranes ]
]

{ #category : #'as yet unclassified' }
PhAspectWeaver class >> objectMembranes [
	^ ObjectInstalledMembranes ifNil: [ObjectInstalledMembranes := WeakKeyToCollectionDictionary  new]
]

{ #category : #private }
PhAspectWeaver class >> panicCleanAndResetAll [
	self uninstallAll.
	self objectMembranes removeAll.
	PhMembraneMethodWrapper processMembraneStack removeAll.
	PhMembraneMethodWrapper processObjectStack removeAll.
	PhMembraneMethodWrapper processObjectDeployedMembraneStack.
	SmalltalkImage current garbageCollect.
]

{ #category : #accessors }
PhAspectWeaver class >> removeMembrane: aMembrane [
	self installedMembranes remove: aMembrane ifAbsent: nil.
]

{ #category : #private }
PhAspectWeaver class >> setInheritancePrecedenceOn: anAdviceCollection [
	| aspectList adviceList workingSet tmp |
	aspectList := Set new.
	aspectList add: PhAspect.
	aspectList addAll: PhAspect allSubclasses.
	adviceList := OrderedCollection new.
	adviceList addAll: (anAdviceCollection select: [:adv | adv owner class theNonMetaClass = PhAspect]).
	workingSet := OrderedCollection with: PhAspect.
	tmp := OrderedCollection new.
	[aspectList notEmpty] whileTrue: [
		tmp removeAll.
		workingSet do: [:father |
			tmp addAll: (aspectList select: [:asp | asp superclass = father]).
			aspectList remove: father].
		tmp do: [:asp |
				adviceList addAll: (anAdviceCollection select: [:adv | adv owner class theNonMetaClass = asp])].
		workingSet removeAll.
		workingSet addAll: tmp].
	^ adviceList.
]

{ #category : #private }
PhAspectWeaver class >> setPrecedenceOn: anAdviceSet [
	"ordenar basado en precedencia"
	| pointcutRulesSet pointcutOverrideRuleSet aspectRulesSet sortedAspects sortedAdvices |
	aspectRulesSet := Set new.
	pointcutRulesSet := Set new.
	pointcutOverrideRuleSet := Set new.
	anAdviceSet do: [:adv |
		(adv owner precedence notEmpty) ifTrue: [aspectRulesSet add: adv owner precedence].
		(adv pointcut precedence notEmpty) ifTrue: [
			(adv pointcut override) 
				ifFalse: [pointcutRulesSet add: adv pointcut precedence]
				ifTrue: [pointcutOverrideRuleSet add: adv pointcut precedence]]].
	((aspectRulesSet isEmpty) & (pointcutRulesSet isEmpty) & (pointcutOverrideRuleSet isEmpty)) ifTrue: [^anAdviceSet].
	(pointcutOverrideRuleSet isEmpty) 
		ifFalse: [
			sortedAspects := PhPrecedenceRulesProcessor new getSortedAspectsWith: pointcutOverrideRuleSet.  
			sortedAdvices := self sort: anAdviceSet from: sortedAspects.  
			(anAdviceSet difference: sortedAdvices) do: [:e | sortedAdvices add: e].
			^sortedAdvices. ]
		ifTrue: [
			sortedAspects := PhPrecedenceRulesProcessor new getSortedAspectsWith: pointcutRulesSet.
			sortedAdvices := self sort: anAdviceSet from: sortedAspects.
			sortedAspects := PhPrecedenceRulesProcessor new getSortedAspectsWith: aspectRulesSet.
			sortedAdvices := self combineOrderOf: sortedAdvices and: (self sort: anAdviceSet from: sortedAspects).
			^sortedAdvices]
]

{ #category : #private }
PhAspectWeaver class >> sort: anAdvicesCollection from: aSortedAspectCollection [
	| sortedAdvices |
	sortedAdvices := OrderedCollection new.
	aSortedAspectCollection do: [:each |
		| col |
		col := anAdvicesCollection select: [:adv | adv owner class = each].
		col do: [:adv | sortedAdvices add: adv]].
	^sortedAdvices.
]

{ #category : #notification }
PhAspectWeaver class >> systemEvent: anEvent [
	self update.
]

{ #category : #'as yet unclassified' }
PhAspectWeaver class >> undeploy:  aMembrane from: anObject [
	self objectMembranes at: anObject 
		ifPresent: [:value | 
			| update |
			update := true.
			value remove: aMembrane ifAbsent: [update := false].
			update ifTrue: [self updateMembranes ]]
]

{ #category : #'install/uninstall' }
PhAspectWeaver class >> uninstallAll [
	self installedAspects do: [:asp | asp uninstall].
	self installedMembranes removeAll.
	self cleanWrappers.  
]

{ #category : #'install/uninstall' }
PhAspectWeaver class >> uninstallMembrane: aMembrane [
	self cleanWrappers.
	self removeMembrane: aMembrane.
	self compileAndInstallMembranes
]

{ #category : #update }
PhAspectWeaver class >> update [
	self updateEnabled
		ifTrue: [ 
			self flushPointcutsMemo.
			PhPointcut resetMemoizedcd.
			self updateMembranes ]
]

{ #category : #accessing }
PhAspectWeaver class >> updateEnabled [
	^ UpdateEnabled ifNil: [UpdateEnabled := true]
]

{ #category : #accessing }
PhAspectWeaver class >> updateEnabled: aBoolean [ 
	UpdateEnabled := aBoolean
]

{ #category : #update }
PhAspectWeaver class >> updateMembranes [
	
	self cleanWrappers.
	self compileAndInstallMembranes
]

{ #category : #notification }
PhAspectWeaver class >> verifyNewClass: anEvent [
	self updateEnabled ifTrue: [self flushPointcutsParser].
	(self mayInclude: anEvent classAdded)
		ifTrue: [ 
			self update ]
]

{ #category : #notification }
PhAspectWeaver class >> verifyNewMethod: anEvent [
	self updateEnabled ifTrue: [self flushPointcutsParser].
	(self includes: anEvent selector on: anEvent methodClass)
		ifTrue: [ 
			self update ]
]
