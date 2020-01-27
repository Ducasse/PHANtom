Class {
	#name : #PhDynamicTests,
	#superclass : #TestCase,
	#category : 'Phantom-Tests'
}

{ #category : #'as yet unclassified' }
PhDynamicTests >> aPhMockClassParserWithPPPInstanceVar [
	^ 'Object subclass: #PhMockClass
	instanceVariableNames: ''counter testString ppp''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: ''Phantom-Tests''' asParser.
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> addFooOnPhNoOneMock [
	(SmalltalkImage current at: #PhNoOneMock) compile: 'foo ^''bar'' '.
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> checkNoOneFoo [
	self assert: ((SmalltalkImage current at: #PhNoOneMock) new foo = 'foo')
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> checkNoOneHash [
	self assert: ((SmalltalkImage current at: #PhNoOneMock) new hash = 'foo')
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> checkPhMockClassFoo [
	
	self assert: ((SmalltalkImage current at: #PhMockClass) new foo = 'foo')
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> checkPhMockSubclassFoo [
	self assert: ((SmalltalkImage current at: #PhMockSubclass) new foo = 'foo')
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> createMockClassSubclass [
	PhMockClass subclass: #PhMockSubclass
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Phantom-Tests'
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> createNoOneClass [
	Object subclass: #PhNoOneMock
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Phantom-Tests'.
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> removeMockSubclass [
	(SmalltalkImage current at: #PhMockSubclass) removeFromSystem.
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> removeNoOneClass [
	(SmalltalkImage current at: #PhNoOneMock) removeFromSystem.
]

{ #category : #tests }
PhDynamicTests >> testClassModification [
	| asp advice |
	[
	advice := (PhAdvice new
		pointcut: (PhPointcut new
			receivers: self aPhMockClassParserWithPPPInstanceVar;
			selectors: 'foo');
			advice: [:ctx | 'foo'];
			type: #around).
			
	asp := (PhAspect new add: advice) install.
	
	asp install.
	self deny: (PhMockClass new foo = 'foo').  
	(PhMockClass addInstVarNamed: 'ccc') new.
		self assert: ((SmalltalkImage current at: #PhMockClass) new foo = 'foo').
	self checkPhMockClassFoo.
	] ensure: [
	asp uninstall.
	PhMockClass removeInstVarNamed: 'ccc'.]
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> testCreateMethod [
	| asp |
	[
	asp := PhAspect new add: (PhAdvice new
		pointcut: (PhPointcut new
			receivers: 'PhNoOneMock';
			selectors: 'foo');
		advice: [:ctx | 'foo'];
		type: #around).
	
	asp install.  
	self addFooOnPhNoOneMock.
	self checkNoOneFoo.
	] ensure: [
	asp uninstall.
	(SmalltalkImage current at: #PhNoOneMock) removeSelector: #foo]
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> testMethodModification [
	| asp |
	[
	asp := PhAspect new add: (PhAdvice new
		pointcut: (PhPointcut new
			receivers: 'PhMockClass';
			selectors: 'foo');
		advice: [:ctx | 'foo'];
		type: #around).
	
	asp install.
	self checkPhMockClassFoo.
	PhMockClass compile: 'foo ^''blah'' '.
	self checkPhMockClassFoo.
	] ensure: [
	asp uninstall.
	PhMockClass compile: 'foo'.]
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> testNewClassOnSystem [
	| asp |
	[self removeNoOneClass.
	
	asp := PhAspect new add: (PhAdvice new
		pointcut: (PhPointcut new
			receivers: 'PhNoOneMock';
			selectors: 'hash');
		advice: [:ctx | 'foo'];
		type: #around).
	
	asp install.
	self createNoOneClass.
	self checkNoOneHash.
	] ensure: [asp uninstall]
	
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> testNewSubClassOnSystem [
	| asp |
	[
	self removeMockSubclass.
	asp := PhAspect new add: (PhAdvice new
		pointcut: (PhPointcut new
			receivers: 'PhMockClass+';
			selectors: 'foo');
		advice: [:ctx | 'foo'];
		type: #around).
	
	asp install.
	self createMockClassSubclass.
	self checkPhMockSubclassFoo.
	] ensure: [asp uninstall]
	
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> testRenameClass [
	| asp |
	[SmalltalkImage current renameClassNamed: 'PhNoOneMock' as: 'PhNoOneOneMock'.
	
	asp := PhAspect new add: (PhAdvice new
		pointcut: (PhPointcut new
			receivers: 'PhNoOneMock';
			selectors: 'hash');
		advice: [:ctx | 'foo'];
		type: #around).
	asp install.
	SmalltalkImage current renameClassNamed: 'PhNoOneOneMock' as: 'PhNoOneMock'.
	self checkNoOneHash] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> testUninstallAfterClassRemove [
	| asp |
	[
	asp := PhAspect new add: (PhAdvice new
		pointcut: (PhPointcut new
			receivers: 'PhNoOneMock';
			selectors: 'hash');
		advice: [:ctx | 'foo'];
		type: #around).
	
	asp install.
	self checkNoOneHash.
	self removeNoOneClass.
	self uninstall: asp.  
	self createNoOneClass.
	] ensure: [
	asp uninstall.
	self createNoOneClass.]
	
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> testUninstallAfterMethodRemove [
	| asp |
	[
	asp := PhAspect new add: (PhAdvice new
		pointcut: (PhPointcut new
			receivers: 'PhNoOneMock';
			selectors: 'foo');
		advice: [:ctx | 'foo'];
		type: #around).
	
	asp install.
	self addFooOnPhNoOneMock.
	self checkNoOneFoo.
	(SmalltalkImage current at: #PhNoOneMock) removeSelector: #foo.
	self uninstall: asp.
	] ensure: [
	asp uninstall.
	(SmalltalkImage current at: #PhNoOneMock) removeSelector: #foo]
]

{ #category : #'as yet unclassified' }
PhDynamicTests >> uninstall: asp [
	asp uninstall.
]
