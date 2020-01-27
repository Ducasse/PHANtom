"
This class is used to define a pointcut.
The joinpoint model is based on messsage reception.
You have to define the receivers of the message, and the message (selectors).
Example:
	PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'foo:'.
	
	To select the metaclass:
	Example:
	PhPointcut new
		receivers: 'PhMockClass class';
		selectors: 'foo:'.
		
You can use some wildcards (like in AspectJ).
Example:
	Any receiver that have MockClass on his name.
	PhPointcut new
		receivers: '*MockClass*';
		selectors: 'foo:'.
		
	PhMockClass and all its subclasses:
	PhPointcut new
		receivers: 'PhMockClass+';
		selectors: 'foo:'.
		
On the selectors you can use '_' for any non argument selector, or '_:' any selector that receive an argument:
Example:
	Any selector of PhMockClass that receive a two argument message.
	PhPointcut new
		receivers: 'PhMockClass';
		selectors: '_:_:'.
		
You can pass groups of receivers and selectors as Arrays
Example:
	PhPointcut new
		receivers: #('Foo' 'Bar' 'SomeClass');
		selectors: #('foo:' 'bar').

You can also pass a PetitParser parser as receivers or selectors.
The classes definition that mathces the parser will be selected as receivers.
On the selectors, the selectors that matches the parser will be selected.

You can define the context to pass to the advices:
	PhPointcut new
		receivers: 'PhMockClass';
		selectors: 'foo:';
		context: #(#receiver #sender #selector #arguments #proceed).
		
You can override the precedence on defined on an aspect with overridePrecedence: #(...).
You can define a different precedence with precedence: #(...), this precedence has higher priority than the precedence defined on the aspects.
You can combine pointcuts using (and) pand: , (or) por: , and not.
Example: 
	(aPointcut1 pand: aPoincut2) por: aPointcut3.
"
Class {
	#name : #PhPointcut,
	#superclass : #Object,
	#instVars : [
		'selectors',
		'receivers',
		'pointcut',
		'composition',
		'selectIfMatch',
		'context',
		'precedence',
		'overrideRules',
		'dynamicContextBlock',
		'selectorsMessage',
		'packageRestriction',
		'cachedRecParser',
		'cachedSelParser',
		'memoizedpc',
		'inCflowOf',
		'ifBlock'
	],
	#classVars : [
		'Memoizedcd',
		'Modifiers'
	],
	#category : 'Phantom-Core'
}

{ #category : #accessing }
PhPointcut class >> memoizedcd [
	Memoizedcd isNil ifTrue:[
		Memoizedcd := SmalltalkImage current allClasses collect: [:cl| cl -> {cl definition . cl class definition}]].
	^ Memoizedcd
]

{ #category : #'instance creation' }
PhPointcut class >> receivers: aReceivers localSelectors: aSelectors [
	^ self new receivers: aReceivers; localSelectors: aSelectors.
]

{ #category : #'instance creation' }
PhPointcut class >> receivers: aReceivers localSelectors: aSelectors context: aContext [
	^ self new receivers: aReceivers; localSelectors: aSelectors; context: aContext.
]

{ #category : #'instance creation' }
PhPointcut class >> receivers: aReceivers localSelectors: aSelectors context: aContext restrict: aRestriction [
	^ self new receivers: aReceivers; localSelectors: aSelectors; context: aContext; restrictToPackages: aRestriction.
]

{ #category : #'instance creation' }
PhPointcut class >> receivers: aReceivers localSelectors: aSelectors restrict: aRestriction [
	^ self new receivers: aReceivers; localSelectors: aSelectors; restrictToPackages: aRestriction.
]

{ #category : #'instance creation' }
PhPointcut class >> receivers: aReceivers selectors: aSelectors [
	^ self new receivers: aReceivers; selectors: aSelectors.
]

{ #category : #'instance creation' }
PhPointcut class >> receivers: aReceivers selectors: aSelectors context: aContext [
	^ self new receivers: aReceivers; selectors: aSelectors; context: aContext.
]

{ #category : #'instance creation' }
PhPointcut class >> receivers: rec selectors: sel context: ctx if: aBlockClosure [ 
	^ (self new)
		receivers: rec;
		selectors: sel;
		context: ctx;
		if: aBlockClosure;
		yourself.
]

{ #category : #'instance creation' }
PhPointcut class >> receivers: aReceivers selectors: aSelectors context: aContext restrict: aRestriction [
	^ self new receivers: aReceivers; selectors: aSelectors; context: aContext; restrictToPackages: aRestriction.
]

{ #category : #'instance creation' }
PhPointcut class >> receivers: aReceivers selectors: aSelectors if: aBlock [
	^ self new receivers: aReceivers; selectors: aSelectors; if: aBlock; yourself.
]

{ #category : #'instance creation' }
PhPointcut class >> receivers: aReceivers selectors: aSelectors restrict: aRestriction [
	^ self new receivers: aReceivers; selectors: aSelectors; restrictToPackages: aRestriction.
]

{ #category : #utility }
PhPointcut class >> receviersParser [
	^ PhReceiverParser new.
]

{ #category : #accessing }
PhPointcut class >> resetMemoizedcd [
	Memoizedcd := nil
]

{ #category : #utility }
PhPointcut class >> selectorsParser [
	^ PhSelectorParser new.
]

{ #category : #composing }
PhPointcut >> & aPointcut [
	^(self copy)
		pointcut: aPointcut;
		composition: #intersection:;
		context: (self mergeContext: aPointcut);
		yourself.    
]

{ #category : #private }
PhPointcut >> checkContextDefinition: anArray [
	| validContextDefs |
	validContextDefs := #(#receiver #sender #selector #arguments #proceed #advice).
	anArray do: [:each |
		(validContextDefs anySatisfy: [:df | df = each])
			ifFalse: [^ false]].
	^ true
]

{ #category : #private }
PhPointcut >> composition [
	^ composition
]

{ #category : #private }
PhPointcut >> composition: anObject [
	composition := anObject
]

{ #category : #accessing }
PhPointcut >> context [
	^ context ifNil: [context := #()]  
]

{ #category : #accessing }
PhPointcut >> context: anArray [ 
	(self checkContextDefinition: anArray)
		ifTrue: [	context := anArray ]
		ifFalse: [self error: 'bad context definition']
]

{ #category : #private }
PhPointcut >> createPointcutList [
	| aSet classes receiversParser selectorsParser |

	self memoizedpc isNil ifFalse: [^self memoizedpc].
	
	aSet := Set new.
	receiversParser := self parseReceivers: self receivers.
	selectorsParser := self parseSelectors: self selectors.
	selectIfMatch
		ifTrue: [ 
			self getClassList
				do: [ :each | aSet addAll: (self pointcutsThatMatchOf: each receiversParser: receiversParser selectorsParser: selectorsParser) ] ]
		ifFalse: [ 
			self getClassList
				do: [ :each | aSet addAll: (self pointcutsThatDontMatchOf: each receiversParser: receiversParser selectorsParser: selectorsParser) ] ].
	
	self memoizedpc: aSet.  
	^ aSet
]

{ #category : #accessing }
PhPointcut >> dynamicContextBlock [
	^dynamicContextBlock
]

{ #category : #accessing }
PhPointcut >> dynamicContextBlock: aContextCreatorBlock [
	dynamicContextBlock := aContextCreatorBlock
]

{ #category : #accessing }
PhPointcut >> getActivePointcutsOnCflowOf: aPhMethodWrapper [
	| pointcuts |
	(self isActiveOnCflowOf: aPhMethodWrapper)
		ifFalse: [ pointcuts := #()]
		ifTrue: [pointcuts := self createPointcutList.].
	(self pointcut notNil) ifTrue: [
		pointcuts := pointcuts perform: (self composition) with: (self pointcut getActivePointcutsOnCflowOf: aPhMethodWrapper)  ].
	^pointcuts
]

{ #category : #private }
PhPointcut >> getClassList [
	self packageRestriction isEmpty
		ifTrue: [ ^ PhPointcut memoizedcd ]
		ifFalse: [ 
			| classes |
			classes := Set new.
			self packageRestriction
				do: [ :packageName | 
					| package |
					package := RPackageOrganizer default packageNamed: packageName ifAbsent: nil.
					package ifNotNil: [ classes addAll: (package classes select: [ :cl | (cl isKindOf: Trait) not ]) ] ].
			^ classes collect: [:cl | cl -> ({cl definition . cl class definition})]]
]

{ #category : #accessing }
PhPointcut >> getMatchedClasses [
	^ (self getPointcuts collect: [:pair | pair at: 1]) asOrderedCollection.
]

{ #category : #accessing }
PhPointcut >> getPointcuts [
	| pointcuts |
	pointcuts := self createPointcutList.
	(self pointcut notNil) ifTrue: [
		pointcuts := pointcuts perform: (self composition) with: (self pointcut getPointcuts)  ].
	^pointcuts
	
]

{ #category : #'as yet unclassified' }
PhPointcut >> if: aBlock [
	ifBlock := aBlock
]

{ #category : #'as yet unclassified' }
PhPointcut >> ifBlock [
	^ ifBlock
]

{ #category : #'as yet unclassified' }
PhPointcut >> inCflowOf: aPointcut [
	^ CflowPointcut newWith: self cflowDef: aPointcut
]

{ #category : #accessing }
PhPointcut >> includes: aSelector on: aClass [
	| includes |
	includes := self localIncludes: aSelector on: aClass.
	self pointcut
		ifNil: [ ^ includes ]
		ifNotNil: [ 
			self composition = #intersection:
				ifTrue: [ ^ includes & (pointcut localIncludes: aSelector on: aClass) ]
				ifFalse: [ ^ includes | (pointcut localIncludes: aSelector on: aClass) ] ]
]

{ #category : #'initialize-release' }
PhPointcut >> initialize [
	pointcut := nil.
	composition := nil.
	selectIfMatch := true.
	overrideRules := false.
	dynamicContextBlock := nil.
	selectorsMessage := #allSelectors.
	packageRestriction := #()
]

{ #category : #'as yet unclassified' }
PhPointcut >> isActiveOnCflowOf: aPhMethodWrapper [
	"inCflowOf ifNil: [^ true].
	^ inCflowOf getPointcuts anySatisfy: [:pc | aCflowStack includes: pc]"

	self pointcut notNil
		ifTrue: [ 
			self composition = #intersection:
				ifTrue: [ ^ true & self pointcut isActiveOnCflowOf: aPhMethodWrapper ] ].
	^ true
]

{ #category : #'as yet unclassified' }
PhPointcut >> isActiveOnContext: ctx [
	^ self ifBlock ifNil: [true] ifNotNil: [self ifBlock value: ctx].
	"pointcut
		ifNil: [^active]
		ifNotNil: [
			self composition = #intersection:
				ifTrue: [^ active & (pointcut isActiveOnContext: ctx)]
				ifFalse: [^ active | (pointcut isActiveOnContext: ctx)]]"
]

{ #category : #'as yet unclassified' }
PhPointcut >> isActiveOnContext: ctx receiver: aReceiverClass selector: aSelector [
	| active |
	(self localIncludes: aSelector on: aReceiverClass )
		ifTrue: [ active := self isActiveOnContext: ctx ]
		ifFalse: [ active := false ].	"active := (self includes: aSelector on: aReceiver class) and: [self isActiveOnContext: ctx]."
	self pointcut
		ifNil: [ ^ active ]
		ifNotNil: [ 
			self composition = #intersection:
				ifTrue: [ ^ active & (self pointcut isActiveOnContext: ctx receiver: aReceiverClass selector: aSelector) ]
				ifFalse: [ ^ active | (self pointcut isActiveOnContext: ctx receiver: aReceiverClass selector: aSelector) ] ]
]

{ #category : #accessing }
PhPointcut >> localIncludes: aSelector on: aClass [
"	(self
		packageRestrictionIncludes: aClass)
		ifTrue: [ 
			| classParser selectorParser |
			classParser := self parseReceivers: self receivers.
			selectorParser := self parseSelectors: self selectors.
			selectIfMatch
				ifTrue: [ 
					(classParser matches: aClass definition)
						ifTrue: [ ^ selectorParser matches: aSelector asString]
						ifFalse: [^ false] ]
				ifFalse: [
					(classParser matches: aClass definition)
						ifTrue: [ ^ (selectorParser matches: aSelector asString) not ]
						ifFalse: [^true]] ]
		ifFalse: [ ^ false ]"
		(self mayInclude: aClass)
			ifTrue: [
				| selectorParser |
				selectorParser := self parseSelectors: self selectors.
				self selectIfMatch
					ifTrue: [ ^ selectorParser matches: aSelector asString]
					ifFalse: [^ (selectorParser matches: aSelector asString) not]]
			ifFalse: [^false]
]

{ #category : #accessing }
PhPointcut >> localSelectors: aParserOrString [
	self setLocal: true.  
	aParserOrString = #()
		ifTrue: [selectors := #any asParser]
		ifFalse: [selectors := aParserOrString]

]

{ #category : #accessing }
PhPointcut >> mayInclude: aClass [
	(self
		packageRestrictionIncludes: aClass)
		ifTrue: [ 
			| classParser |
			classParser := self parseReceivers: self receivers.
			self selectIfMatch
				ifTrue: [ 
					^ (classParser matches: aClass definition)]
				ifFalse: [
					^ (classParser matches: aClass definition) not] ]
		ifFalse: [ ^ false ]
]

{ #category : #accessing }
PhPointcut >> memoizedpc [
	^ memoizedpc
]

{ #category : #accessing }
PhPointcut >> memoizedpc: anObject [
	memoizedpc := anObject
]

{ #category : #composing }
PhPointcut >> mergeContext: aPointcut [
	|newctx|
	newctx := self context asSet.
	newctx addAll: aPointcut context.
	^newctx asArray.  
	
]

{ #category : #composing }
PhPointcut >> not [
	^(self copy)
		pointcut: (self pointcut ifNotNil: [self pointcut not]);
		composition: ((self composition) ifNotNil: [
			(self composition = #intersecton:) ifTrue: [#union:] ifFalse: [#intersection:]]);
		selectIfMatch: self selectIfMatch not;  
		yourself. 
]

{ #category : #'as yet unclassified' }
PhPointcut >> notInCflowOf: aPointcut [
	^ (CflowPointcut newWith: self cflowDef: aPointcut) not
]

{ #category : #accessing }
PhPointcut >> override [
	^overrideRules
]

{ #category : #accessing }
PhPointcut >> override: aBoolean [
	overrideRules := aBoolean.
]

{ #category : #accessing }
PhPointcut >> overridePrecedence: anArray [ 
	overrideRules := true.
	precedence := anArray
]

{ #category : #accessing }
PhPointcut >> packageRestriction [
	^ packageRestriction
]

{ #category : #accessing }
PhPointcut >> packageRestrictionIncludes: aClass [
	self packageRestriction isEmpty
		ifTrue: [ ^ true ]
		ifFalse: [ 
			self packageRestriction
				do: [ :packageName | 
					| package |
					package := PackageOrganizer default packageNamed: packageName ifAbsent: nil.
					package
						ifNotNil: [ 
							(package includesClass: aClass)
								ifTrue: [ ^ true ] ] ].
			^ false ]
]

{ #category : #composing }
PhPointcut >> pand: aPointcut [
	self deprecated: 'Use & intead'
]

{ #category : #private }
PhPointcut >> parseReceivers: receiversDefinition [
	^ cachedRecParser
		ifNil: [ 
			cachedRecParser := receiversDefinition isPetitParser
				ifTrue: [ receiversDefinition ]
				ifFalse: [ 
					receiversDefinition isString
						ifTrue: [ PhPointcut receviersParser parse: receiversDefinition ]
						ifFalse: [ 
							receiversDefinition size = 1
								ifTrue: [ PhPointcut receviersParser parse: (receiversDefinition at: 1) ]
								ifFalse: [ 
									receiversDefinition
										reduce: [ :a :b | 
											| parserA parserB |
											a isPetitParser
												ifTrue: [ parserA := a ]
												ifFalse: [ parserA := PhPointcut receviersParser parse: a ].
											b isPetitParser
												ifTrue: [ parserB := b ]
												ifFalse: [ parserB := PhPointcut receviersParser parse: b ].
											parserA / parserB ] ] ] ] ]
]

{ #category : #private }
PhPointcut >> parseSelectors: selectorsDefinition [
	^ cachedSelParser
		ifNil: [ 
			cachedSelParser := selectorsDefinition isPetitParser
				ifTrue: [ selectorsDefinition ]
				ifFalse: [ 
					selectorsDefinition isString
						ifTrue: [ PhPointcut selectorsParser parse: selectorsDefinition ]
						ifFalse: [ 
							selectorsDefinition size = 1
								ifTrue: [ PhPointcut selectorsParser parse: (selectorsDefinition at: 1) asString ]
								ifFalse: [ 
									selectorsDefinition
										reduce: [ :a :b | 
											| pa pb |
											a isPetitParser
												ifTrue: [ pa := a ]
												ifFalse: [ pa := PhPointcut selectorsParser parse: a ].
											b isPetitParser
												ifTrue: [ pb := b ]
												ifFalse: [ pb := PhPointcut selectorsParser parse: b ].
											pa / pb ] ] ] ] ]	"| receiversList sel |
	receiversList := self expandReceivers.
	sel := (selectorsString subStrings: ' ') collect: [:e | e asSymbol].
	^ receiversList collect: [:r | sel]"
]

{ #category : #private }
PhPointcut >> pointcut [
	^ pointcut
]

{ #category : #private }
PhPointcut >> pointcut: anObject [
	pointcut := anObject
]

{ #category : #private }
PhPointcut >> pointcutsThatDontMatchOf: aClassNDescs receiversParser: receiversParser selectorsParser: selectorsParser [
	| aCollection aClass|
	aClass := aClassNDescs key.
	aCollection := OrderedCollection new.
	(receiversParser matches: (aClassNDescs value at: 1)) not
		ifTrue: [ (self selectorsMessage value: aClass) do: [ :sel | aCollection add: (Array with: aClass with: sel) ] ]
		ifFalse: [ 
			(self selectorsMessage value: aClass)
				do: [ :sel | 
					(selectorsParser matches: sel asString) not
						ifTrue: [ aCollection add: (Array with: aClass with: sel) ] ].
			(self selectorsMessage = #localSelectors)
				ifTrue: [
					(aClass allSelectors difference: (aClass localSelectors)) do: [:each | aCollection add: (Array with: aClass with: each)] ] ].
	(receiversParser matches: (aClassNDescs value at: 2)) not
		ifTrue: [ (self selectorsMessage value: aClass class) do: [ :sel | aCollection add: (Array with: aClass class with: sel) ] ]
		ifFalse: [ 
			(self selectorsMessage value: aClass class)
				do: [ :sel | 
					(selectorsParser matches: sel asString) not
						ifTrue: [ aCollection add: (Array with: aClass class with: sel) ] ].
			(self selectorsMessage = #localSelectors)
				ifTrue: [
					(aClass class allSelectors difference: (aClass class localSelectors)) do: [:each | aCollection add: (Array with: aClass class with: each)] ] ].
	^ aCollection
]

{ #category : #private }
PhPointcut >> pointcutsThatMatchOf: aClassNDescs receiversParser: receiversParser selectorsParser: selectorsParser [
	| aCollection aClass|
	aCollection := OrderedCollection new.
	aClass := aClassNDescs key.
	(receiversParser matches: (aClassNDescs value at: 1))
		ifTrue: [ 
			(self selectorsMessage value: aClass)
				do: [ :sel | 
					(selectorsParser matches: sel asString)
						ifTrue: [ aCollection add: (Array with: aClass with: sel) ] ] ].
	(receiversParser matches: (aClassNDescs value at: 2))
		ifTrue: [ 
			(self selectorsMessage value: aClass class)
				do: [ :sel | 
					(selectorsParser matches: sel asString)
						ifTrue: [ aCollection add: (Array with: aClass class with: sel) ] ] ].
	^ aCollection
]

{ #category : #composing }
PhPointcut >> por: aPointcut [
	self deprecated: 'Use | instead'
]

{ #category : #accessing }
PhPointcut >> precedence [
	^precedence ifNil: [precedence := #()]
]

{ #category : #accessing }
PhPointcut >> precedence: anArray [
	overrideRules := false.
	precedence := anArray
]

{ #category : #accessing }
PhPointcut >> receivers [
	^receivers ifNil: [#any asParser star not]
]

{ #category : #accessing }
PhPointcut >> receivers: aParserOrString [
	cachedRecParser := nil.
	receivers := aParserOrString
]

{ #category : #private }
PhPointcut >> resetParsers [
	cachedRecParser := nil.
	cachedSelParser := nil.
]

{ #category : #accessing }
PhPointcut >> restrictToPackages: aPackageNameArray [
	packageRestriction := aPackageNameArray
]

{ #category : #private }
PhPointcut >> selectIfMatch [
	^selectIfMatch
]

{ #category : #private }
PhPointcut >> selectIfMatch: aBoolean [
	selectIfMatch := aBoolean
]

{ #category : #accessing }
PhPointcut >> selectors [
	^selectors ifNil: [#any asParser star not]
]

{ #category : #accessing }
PhPointcut >> selectors: aParserOrString [
	self setLocal: false.
	cachedSelParser := nil.
	aParserOrString = #()
		ifTrue: [selectors := #any asParser]
		ifFalse: [selectors := aParserOrString]

]

{ #category : #private }
PhPointcut >> selectorsMessage [
	^ selectorsMessage
]

{ #category : #private }
PhPointcut >> selectorsMessage: aSelectorsMessage [
	selectorsMessage :=  aSelectorsMessage
]

{ #category : #private }
PhPointcut >> setLocal: aBoolean [
	aBoolean 
		ifTrue: [selectorsMessage := #localSelectors]  
		ifFalse: [selectorsMessage := #allSelectors] 
]

{ #category : #composing }
PhPointcut >> | aPointcut [
	^(self copy)
		pointcut: aPointcut;
		composition: #union:;
		context: (self mergeContext: aPointcut);
		yourself.  
]
