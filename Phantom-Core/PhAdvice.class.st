"
PhAdvice represents a pointcut, advice pair.
Use pointcut:  to declare the joinpoint to capture, using an instance of PhPointcut.
Use type: to declare the type of the advice,
	#before
	#after
	#around.
Use advice: to add the method to execute on the captued joinpoints.
advice: accept a block or a selector, with 0 arguments (if no context is captured on the pointcut), or 1 arguments for the context captured on the joinpoint.
you can also use selector:of: to send a message on an object for advice.
Example: 
	PhAdvice new
		pointcut: aPointcut;
		type: #before;
		advice: [:context | Transcript show: context receiver asString].
		
	PhAdvice new
		pointcut: aPointcut;
		type: #around;
		selector: #theAdviceOnFoo: of: foo.  
"
Class {
	#name : #PhAdvice,
	#superclass : #Object,
	#instVars : [
		'type',
		'pointcut',
		'advice',
		'owner'
	],
	#category : 'Phantom-Core'
}

{ #category : #'instance creation' }
PhAdvice class >> after: aPC advice: aBlock [
	^self new pointcut: aPC; advice: aBlock; type: #after.
]

{ #category : #'instance creation' }
PhAdvice class >> after: aPC send: aSymbol to: anObject [ 
	^self new pointcut: aPC; send: aSymbol to: anObject; type: #after.
]

{ #category : #'instance creation' }
PhAdvice class >> around: aPC advice: aBlock [
	^self new pointcut: aPC; advice: aBlock; type: #around
]

{ #category : #'instance creation' }
PhAdvice class >> around: aPC send: aSymbol to: anObject [ 
	^self new pointcut: aPC; send: aSymbol to: anObject; type: #around.
]

{ #category : #'instance creation' }
PhAdvice class >> before: aPC advice: aBlock [
	^self new pointcut: aPC; advice: aBlock; type: #before.
]

{ #category : #'instance creation' }
PhAdvice class >> before: aPC send: aSymbol to: anObject [ 
	^self new pointcut: aPC; send: aSymbol to: anObject; type: #before.
]

{ #category : #accessing }
PhAdvice >> advice: aBlock [
	advice := aBlock
]

{ #category : #'as yet unclassified' }
PhAdvice >> isActiveOnCflowOf: aPhMethodWrapper [
	^ self pointcut isActiveOnCflowOf: aPhMethodWrapper.
]

{ #category : #private }
PhAdvice >> owner [
	^ owner 
]

{ #category : #private }
PhAdvice >> owner: anAspect [
	owner := anAspect
]

{ #category : #accessing }
PhAdvice >> pointcut [
	^ pointcut
]

{ #category : #accessing }
PhAdvice >> pointcut: aPhPointcut [
	pointcut := aPhPointcut
]

{ #category : #private }
PhAdvice >> runWithin: aContext [
	^(advice value: aContext)
]

{ #category : #accessing }
PhAdvice >> send: aSymbol to: anObject [
	self advice: [:contxt | anObject perform: aSymbol with: contxt]
]

{ #category : #accessing }
PhAdvice >> type [
	^ type ifNil: [type := #before]
]

{ #category : #accessing }
PhAdvice >> type: aSymbol [
	type := aSymbol
]
