Class {
	#name : #PhMembraneMethodWrapper,
	#superclass : #PhMethodWrapper,
	#instVars : [
		'membranes',
		'cflowStack'
	],
	#classVars : [
		'ProcessMembraneStack',
		'ProcessObjectDeployedMembraneStack',
		'ProcessObjectStack'
	],
	#category : 'Phantom-Core'
}

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> currentObjectDeployedMembraneStack [
	^ self processObjectDeployedMembraneStack at: (Processor activeProcess) ifAbsent: [#()]
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> currentProcessMembraneStack [
	^ self processMembraneStack at: (Processor activeProcess) ifAbsent: [#()]
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> currentProcessObjectStack [
	^ self processObjectStack at: (Processor activeProcess) ifAbsent: [#()]
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> on: aClass selector: aSelector with: aMembraneArray [
	^ (super on: aClass selector: aSelector)
		membranes: aMembraneArray;
		yourself
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> popObjectOnCurrentProcess [
	self processObjectStack at: (Processor activeProcess) 
		ifPresent: [:col | col ifNotEmpty: [:collection | collection removeLast] ]
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> processMembraneStack [
	^ ProcessMembraneStack ifNil: [ProcessMembraneStack := WeakKeyToCollectionDictionary new]
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> processObjectDeployedMembraneStack [
	^ ProcessObjectDeployedMembraneStack ifNil: [ProcessObjectDeployedMembraneStack := WeakKeyToCollectionDictionary new]
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> processObjectStack [
	^ ProcessObjectStack ifNil: [ProcessObjectStack := WeakKeyToCollectionDictionary new]
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> setActiveMembranes: aMembraneArray [
	self processMembraneStack at: (Processor activeProcess) put: aMembraneArray
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> setObjectDeployedActiveMembranes: aMembraneArray [
	self processObjectDeployedMembraneStack at: (Processor activeProcess) put: aMembraneArray
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper class >> stackObjectOnCurrentProcess: anObject [
	self processObjectStack at: (Processor activeProcess) 
		ifPresent: [:col | col add: anObject]
		ifAbsent: [self processObjectStack at: (Processor activeProcess) put: (OrderedCollection with: anObject)]
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper >> activeObjectDeployedMembraneSet [
	| mbrSet callStack |
	callStack := PhMembraneMethodWrapper currentProcessObjectStack.
	mbrSet := Set new.
	callStack do: [:rc |
		PhAspectWeaver objectMembranes at: rc ifPresent: [:mbr | mbrSet addAll: mbr]].
	^ mbrSet.
"	| ct mbrSet callStack |
	mbrSet := Set new.
	callStack := thisContext contextStack.
	callStack do: [:each |
		PhAspectWeaver objectMembranes at: (each receiver) ifPresent: [:mbr | mbrSet addAll: mbr] ].
	^ mbrSet"
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper >> currentObjectDeployedMembraneStack [
	^ PhMembraneMethodWrapper currentObjectDeployedMembraneStack ifEmpty: [self activeObjectDeployedMembraneSet asArray]
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper >> currentProcessMembraneStack [
	^ PhMembraneMethodWrapper currentProcessMembraneStack ifEmpty: [self membranes select: [:mbr | mbr isBaseMembrane]] 
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper >> getAdviceFrom: aMembraneSet and: objMembraneSet [
	| aspectsSet advice stack |
	cflowStack := nil.
	aspectsSet := Set new.
	advice := OrderedCollection new.
	aMembraneSet do: [ :each | aspectsSet addAll: each registeredAspects ].
	objMembraneSet do: [:each | aspectsSet addAll: each registeredAspects ].
	aspectsSet
		do: [ :asp | 
			asp adviceCollection
				do: [ :adv | 
					(adv pointcut includes: self selector on: self wrappedClass)
						ifTrue: [ advice add: adv ] ] ].
"	self halt."
	advice removeAllSuchThat: [:adv | (adv isActiveOnCflowOf: self) not].
	advice := PhAspectWeaver setPrecedenceOn: (PhAspectWeaver setInheritancePrecedenceOn: advice asArray).
	^ advice
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper >> getCallStack [
	cflowStack isNil ifFalse: [^ cflowStack].
	cflowStack := OrderedCollection new.
	thisContext stack
		do: [ :snd | 
			| receiver selector |
			(snd receiver isKindOf: PhMethodWrapper) & (snd selector = #run:with:in:)
				ifTrue: [ 
					receiver := snd receiver wrappedClass.
					selector := snd receiver selector ]
				ifFalse: [ 
					receiver := snd receiver class.
					selector := snd selector ].
			cflowStack add: (Array with: receiver with: selector) ].
	^ cflowStack
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper >> getMembraneSetFor: activeMembranes [
	activeMembranes 
		ifEmpty: [^ self membranes select: [:mbr | mbr isBaseMembrane ]]
		ifNotEmpty: [:mbrGrp | 
			| mbrSet |
			mbrSet := Set new.
			mbrGrp do: [:each | mbrSet addAll: each advisingMembranes].
			mbrSet := mbrSet select: [:mb | (mb pointcut = nil) or: [mb pointcut includes: (self selector) on: self wrappedClass]].
			^ mbrSet] 
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper >> getObjectDeployedMembraneSetFor: activeMembranes [
	activeMembranes 
		ifEmpty: [^ self activeObjectDeployedMembraneSet select: [:mbr | mbr isBaseMembrane ]]
		ifNotEmpty: [:mbrGrp | 
			| mbrSet |
			mbrSet := Set new.
			mbrGrp do: [:each | mbrSet addAll: each advisingMembranes].
			mbrSet := mbrSet select: [:mb | (mb pointcut = nil) or: [mb pointcut includes: (self selector) on: self wrappedClass]].
			^ mbrSet] 
]

{ #category : #accessing }
PhMembraneMethodWrapper >> membranes [
	^ membranes
]

{ #category : #accessing }
PhMembraneMethodWrapper >> membranes: aMembraneArray [
	membranes := aMembraneArray
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper >> run: aSelector with: arguments in: aReceiver [
	| result membraneStack advice advMembranes objectDeployedMembraneStack objAdvMembranes objectStart stackStart |
	PhMembraneMethodWrapper stackObjectOnCurrentProcess:  aReceiver. 
	membraneStack := self currentProcessMembraneStack.
	objectDeployedMembraneStack := self currentObjectDeployedMembraneStack.
	advMembranes := self getMembraneSetFor:  membraneStack.
	objAdvMembranes := self getObjectDeployedMembraneSetFor:  objectDeployedMembraneStack.
	advice := self getAdviceFrom:  advMembranes and: objAdvMembranes. 
	objectStart := PhMembraneMethodWrapper currentObjectDeployedMembraneStack isEmpty.
	stackStart := PhMembraneMethodWrapper currentProcessMembraneStack isEmpty.
	result :=  (PhAdviceGroup new)
		adviceCollection: advice;
		advisingMembranes: advMembranes;
		objectDeployedAdvisingMembranes: objAdvMembranes;
		wrapper: self;
		run: aSelector with: arguments in: aReceiver.
	PhMembraneMethodWrapper popObjectOnCurrentProcess.
	objectStart ifTrue: [self setObjectDeployedActiveMembranes: #()].
	stackStart ifTrue: [self setActiveMembranes: #()].
	^ result.
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper >> setActiveMembranes:  aMembraneArray [ 
	PhMembraneMethodWrapper setActiveMembranes:  aMembraneArray 
]

{ #category : #'as yet unclassified' }
PhMembraneMethodWrapper >> setObjectDeployedActiveMembranes:  aMembraneArray [
	PhMembraneMethodWrapper  setObjectDeployedActiveMembranes:  aMembraneArray
]
