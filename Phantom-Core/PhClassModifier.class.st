"
This class is use to declare the modification to do on a class, at the moment of install an aspect.
You can add instance variables, class variables, instance methods and class side methods.
This modifications are rolled back on uninstall.
"
Class {
	#name : #PhClassModifier,
	#superclass : #Object,
	#instVars : [
		'pointcut',
		'newInstanceMethodDict',
		'newClassMethodDict',
		'newInstanceVar',
		'newClassVar',
		'modifiedClasses'
	],
	#category : 'Phantom-Core'
}

{ #category : #'instance creation' }
PhClassModifier class >> on: aPointcut addCM: aCMString [
	^self new on: aPointcut; addNewClassMethod: aCMString
  
]

{ #category : #'instance creation' }
PhClassModifier class >> on: aPointcut addCV: aCVString [
	^self new on: aPointcut; addNewClassVar: aCVString
]

{ #category : #'instance creation' }
PhClassModifier class >> on: aPointcut addCV: aCVString addCM: aCMString [
	^self new on: aPointcut; addNewClassVar: aCVString; addNewClassMethod: aCMString
  
]

{ #category : #'instance creation' }
PhClassModifier class >> on: aPointcut addIM: aIMString [
	^self new on: aPointcut; addNewInstanceMethod: aIMString   
	
]

{ #category : #'instance creation' }
PhClassModifier class >> on: aPointcut addIV: aIVString [
	^self new on: aPointcut; addNewInstanceVar: aIVString
]

{ #category : #'instance creation' }
PhClassModifier class >> on: aPointcut addIV: aIVString addIM: aIMString [
	^self new on: aPointcut; addNewInstanceVar: aIVString; addNewInstanceMethod: aIMString   
	
]

{ #category : #'method-manipulation' }
PhClassModifier >> addNewClassMethod: aMethodString [
	| aSelector |
	aSelector := (RBParser parseMethod: aMethodString) selector.
	modifiedClasses do: [:class |
		(class theMetaClass allSelectors includes: aSelector)
			ifFalse: [newClassMethodDict add: (aSelector -> aMethodString)]
			ifTrue: [self error: 'method already defined']]
	"(modifiedClass theMetaClass allSelectors includes: aSelector)
		ifFalse: 	[newClassMethodDict add: (aSelector -> aMethodString)]
		ifTrue: [self error: 'method already defined']"
]

{ #category : #'variable-manipulation' }
PhClassModifier >> addNewClassVar: aClassVarName [
	| varName |
	varName := aClassVarName capitalized.
	modifiedClasses do: [:class |
		(class hasClassVarNamed: varName)
			ifFalse: [newClassVar add: varName]
			ifTrue: [self error: 'variable already defined']]
	"(modifiedClass hasClassVarNamed: varName) 
		ifFalse:	[newClassVar add: varName]
		ifTrue: [self error: 'variable already defined']"
]

{ #category : #'method-manipulation' }
PhClassModifier >> addNewInstanceMethod: aMethodString [
	| aSelector |
	aSelector := (RBParser parseMethod: aMethodString) selector.
	modifiedClasses do: [:each |
		(each allSelectors includes: aSelector)
			ifFalse: [newInstanceMethodDict add: (aSelector -> aMethodString)]
			ifTrue: [self error: 'method already defined']]
	"(modifiedClass allSelectors includes: aSelector)
		ifFalse: 	[newInstanceMethodDict add: (aSelector -> aMethodString)]
		ifTrue: [self error: 'method already defined']"
]

{ #category : #'variable-manipulation' }
PhClassModifier >> addNewInstanceVar: anInstanceVarName [
	modifiedClasses do: [:each | 
		(each hasInstVarNamed: anInstanceVarName)
			ifFalse:	[newInstanceVar add: anInstanceVarName]
			ifTrue: [self error: 'variable already defined']]
	"(modifiedClass hasInstVarNamed: anInstanceVarName) 
		ifFalse:	[newInstanceVar add: anInstanceVarName]
		ifTrue: [self error: 'variable already defined']"
]

{ #category : #private }
PhClassModifier >> checkExistence [
	modifiedClasses
		do: [ :modifiedClass | 
			newInstanceVar
				do: [ :varName | 
					(modifiedClass theNonMetaClass hasInstVarNamed: varName)
						ifTrue: [ self error: 'instance variable already defined!' ] ].
			newClassVar
				do: [ :varName | 
					(modifiedClass theNonMetaClass hasClassVarNamed: varName)
						ifTrue: [ self error: 'class variable already defined!' ] ].
			newInstanceMethodDict
				keysDo: [ :selector | 
					(modifiedClass theNonMetaClass allSelectors includes: selector)
						ifTrue: [ self error: 'instance method already defined!' ] ].
			newClassMethodDict
				keysDo: [ :selector | 
					(modifiedClass theMetaClass allSelectors includes: selector)
						ifTrue: [ self error: 'class method already defined!' ] ] ]
	"newInstanceVar do: [:varName |
		(modifiedClass theNonMetaClass hasInstVarNamed: varName) ifTrue: [self error: 'instance variable already defined!']].
	newClassVar do: [:varName |
		(modifiedClass theNonMetaClass hasClassVarNamed: varName) ifTrue: [self error: 'class variable already defined!']].
	newInstanceMethodDict keysDo: [:selector |
		(modifiedClass theNonMetaClass allSelectors includes: selector) ifTrue: [self error: 'instance method already defined!']].
	newClassMethodDict keysDo: [:selector |
		(modifiedClass theMetaClass allSelectors includes: selector) ifTrue: [self error: 'class method already defined!']]"
]

{ #category : #private }
PhClassModifier >> compileClassMethod: aMethodString [
	modifiedClasses do: [:modifiedClass |
		modifiedClass theMetaClass compile: aMethodString classified: '*phantom-generated-method']
	
]

{ #category : #private }
PhClassModifier >> compileMethod: aMethodString [
	modifiedClasses do: [:modifiedClass |
		modifiedClass compile: aMethodString classified: '*phantom-generated-method'  ]
	
]

{ #category : #'as yet unclassified' }
PhClassModifier >> filterMatchedClasses: aClassCollection [
	"fliter classes by object hierarchy"
	| filteredCollection |
	filteredCollection := OrderedCollection withAll: aClassCollection.
	aClassCollection do: [:each |
		| subclasses |
		subclasses := each allSubclasses.
		filteredCollection := filteredCollection reject: [:class | subclasses includes: class]].
	^ filteredCollection
	
]

{ #category : #'initialize-release' }
PhClassModifier >> initialize [
	newInstanceMethodDict := Dictionary new.
	newClassMethodDict := Dictionary new.
	newInstanceVar := Set new.
	newClassVar := Set new.
]

{ #category : #'install-uninstall' }
PhClassModifier >> install [
	modifiedClasses := self filterMatchedClasses: self pointcut getMatchedClasses.
	self checkExistence.
	modifiedClasses
		do: [ :modifiedClass | 
			newInstanceVar do: [ :varName | modifiedClass theNonMetaClass addInstVarNamed: varName ].
			newClassVar do: [ :varName | modifiedClass theNonMetaClass addClassVarNamed: varName ].
			newClassMethodDict do: [ :methodString | self compileClassMethod: methodString ].
			newInstanceMethodDict do: [ :methodString | self compileMethod: methodString ] ]
]

{ #category : #'initialize-release' }
PhClassModifier >> on: aPointcut [
	pointcut := aPointcut.
	modifiedClasses := self filterMatchedClasses:  (aPointcut getMatchedClasses).
]

{ #category : #private }
PhClassModifier >> pointcut [
	^ pointcut
]

{ #category : #private }
PhClassModifier >> removeClassVar: aClassVarName [
	newClassVar remove: aClassVarName
]

{ #category : #private }
PhClassModifier >> removeInstanceVar: anIntanceVarName [
	newInstanceVar remove: anIntanceVarName
]

{ #category : #'install-uninstall' }
PhClassModifier >> uninstall [
	modifiedClasses
		do: [ :modifiedClass | 
			newClassMethodDict keysDo: [ :selector | modifiedClass theMetaClass removeSelector: selector ].
			newInstanceMethodDict keysDo: [ :selector | modifiedClass theNonMetaClass removeSelector: selector ].
			modifiedClass organization removeEmptyCategories.
			modifiedClass theMetaClass organization removeEmptyCategories.
			newClassVar do: [ :classVarName | modifiedClass theNonMetaClass removeClassVarNamed: classVarName ].
			newInstanceVar do: [ :instanceVarName | modifiedClass theNonMetaClass removeInstVarNamed: instanceVarName ] ]
]
