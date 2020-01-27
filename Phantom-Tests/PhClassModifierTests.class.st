Class {
	#name : #PhClassModifierTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'as yet unclassified' }
PhClassModifierTests >> testAddNewClassMethod [
	| aClassModifier |
	[aClassModifier := PhClassModifier new on: (PhPointcut receivers: 'PhMockClass' selectors: #any asParser).
	self deny: (PhMockClass theMetaClass localSelectors includes: #theTestMethod).  
	aClassModifier addNewClassMethod: 'theTestMethod
		^''success'' '.  
	aClassModifier install.
	self assert: (PhMockClass theTestMethod = 'success').] ensure: [
	aClassModifier uninstall.
	self deny: (PhMockClass theMetaClass localSelectors includes: #theTestMethod).]
	    
]

{ #category : #'as yet unclassified' }
PhClassModifierTests >> testAddNewClassVar [
	| aClassModifier |
	[aClassModifier := PhClassModifier new on: (PhPointcut receivers: 'PhMockClass' selectors: #any asParser).
	self deny: (PhMockClass hasClassVarNamed: 'Asdf').
	aClassModifier addNewClassVar: 'Asdf'.
	aClassModifier install.
	self assert: (PhMockClass hasClassVarNamed: 'Asdf').] ensure: [
	aClassModifier uninstall.
	self deny: (PhMockClass hasClassVarNamed: 'Asdf')]
	    
]

{ #category : #'as yet unclassified' }
PhClassModifierTests >> testAddNewInstanceMethod [
	| aClassModifier |
	[aClassModifier := PhClassModifier new on: (PhPointcut receivers: 'PhMockClass' selectors: #any asParser ).
	self deny: (PhMockClass theNonMetaClass localSelectors includes: #theTestMethod).  
	aClassModifier addNewInstanceMethod: 'theTestMethod
		^''success'' '.  
	aClassModifier install.
	self assert: (PhMockClass new theTestMethod = 'success').] ensure: [
	aClassModifier uninstall.
	self deny: (PhMockClass theNonMetaClass localSelectors includes: #theTestMethod).]
	    
]

{ #category : #'as yet unclassified' }
PhClassModifierTests >> testAddNewInstanceVar [
	| aClassModifier |
	[aClassModifier := PhClassModifier new on: (PhPointcut receivers: 'PhMockClass' selectors: #any asParser).
	self deny: (PhMockClass hasInstVarNamed: 'asdf').
	aClassModifier addNewInstanceVar: 'asdf'.
	aClassModifier install.
	self assert: (PhMockClass hasInstVarNamed: 'asdf').] ensure: [
	aClassModifier uninstall.
	self deny: (PhMockClass hasInstVarNamed: 'asdf')]
	    
]

{ #category : #'as yet unclassified' }
PhClassModifierTests >> testCompleModification [
	| aClassModifier mock |
	[aClassModifier := PhClassModifier new on: (PhPointcut receivers: 'PhMockClass' selectors: #any asParser).
	aClassModifier
		addNewInstanceVar: 'xxxVar';
		addNewInstanceMethod: 'plusXXX
			xxxVar := self xxxVar +1';
		addNewInstanceMethod: 'xxxVar
			^ xxxVar ifNil: [xxxVar := 0]'.
	aClassModifier install.
	mock := PhMockClass new.
	self assert: (mock xxxVar = 0).
	mock plusXXX.
	self assert: (mock xxxVar = 1).] ensure: [
	aClassModifier uninstall.] 	
	
]

{ #category : #accessing }
PhClassModifierTests >> testMultipointcut [
	| pc cm |
	pc := PhPointcut new
		receivers: #('PhMockClass' 'PhMockAspectFoo');
		selectors: #any asParser.
	
	cm := PhClassModifier new on: pc.
	cm 
		addNewInstanceVar: 'foobarVar';
		addNewInstanceMethod: 'foobarMethod ^true'.
	[cm install.
	self assert: (PhMockClass hasInstVarNamed: 'foobarVar').
	self assert: (PhMockClass methodDict includesKey: #foobarMethod).
	self assert: (PhMockClass new perform: #foobarMethod).
	self assert: (PhMockAspectFoo hasInstVarNamed: 'foobarVar').
	self assert: (PhMockAspectFoo methodDict includesKey: #foobarMethod).
	self assert: (PhMockAspectFoo new perform: #foobarMethod).] ensure: [cm uninstall]
]

{ #category : #accessing }
PhClassModifierTests >> testPointcutWithSubclasses [
	| pc cm |
	pc := PhPointcut new
		receivers: #('PhMockClass+' 'PhMockAspectFoo+');
		selectors: #any asParser.
	
	cm := PhClassModifier new on: pc.
	cm 
		addNewInstanceVar: 'foobarVar';
		addNewInstanceMethod: 'foobarMethod ^true'.
	[cm install.
	self assert: (PhMockClass hasInstVarNamed: 'foobarVar').
	self assert: (PhMockClass methodDict includesKey: #foobarMethod).
	self assert: (PhMockClass new perform: #foobarMethod).
	self assert: (PhMockSubclass allSelectors includes: #foobarMethod).
	self assert: (PhMockSubclass new perform: #foobarMethod).
	self assert: (PhMockAspectFoo hasInstVarNamed: 'foobarVar').
	self assert: (PhMockAspectFoo methodDict includesKey: #foobarMethod).
	self assert: (PhMockAspectFoo new perform: #foobarMethod).
	self assert: (PhMockFooAspect5 allSelectors includes: #foobarMethod).
	self assert: (PhMockFooAspect5 new perform: #foobarMethod).] ensure: [cm uninstall]
	
	
	
]

{ #category : #'as yet unclassified' }
PhClassModifierTests >> testSimplePointcutAsArgument [
	| pc cm |
	pc := PhPointcut new
		receivers: 'PhMockClass';
		selectors: #any asParser.
	
	cm := PhClassModifier new on: pc.
	cm 
		addNewInstanceVar: 'foobarVar';
		addNewInstanceMethod: 'foobarMethod ^true'.
	[cm install.
	self assert: (PhMockClass hasInstVarNamed: 'foobarVar').
	self assert: (PhMockClass methodDict includesKey: #foobarMethod).
	self assert: (PhMockClass new perform: #foobarMethod)] ensure: [cm uninstall]
	
	
	
]
