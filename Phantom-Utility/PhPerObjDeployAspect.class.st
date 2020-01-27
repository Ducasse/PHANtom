"
A deployment aspect that instantiates and deploys one aspect for each instantiation of an object of the class pattern. The aspect instance is sent the targetmethod message with argument the object just instantiated so it can keep track of it.

See PhPerObjExampleAspect for an example
"
Class {
	#name : #PhPerObjDeployAspect,
	#superclass : #PhAspect,
	#instVars : [
		'targetmethod',
		'classpattern',
		'aspectclass'
	],
	#category : 'Phantom-Utility'
}

{ #category : #'instance creation' }
PhPerObjDeployAspect class >> onClassPattern: aClassPat instantiate: anAspectClass targetmethod: aSymbol [
	|asp|
	asp := self basicNew.
	asp classpattern: aClassPat.
	asp aspectclass:  anAspectClass.
	asp targetmethod: aSymbol.  
	asp initialize.
	^asp.
]

{ #category : #accessing }
PhPerObjDeployAspect >> aspectclass [
	^ aspectclass
]

{ #category : #accessing }
PhPerObjDeployAspect >> aspectclass: anObject [
	aspectclass := anObject
]

{ #category : #accessing }
PhPerObjDeployAspect >> classpattern [
	^ classpattern
]

{ #category : #accessing }
PhPerObjDeployAspect >> classpattern: anObject [
	classpattern := anObject
]

{ #category : #'initialize-release' }
PhPerObjDeployAspect >> initialize [
	super initialize.
	self add:
		(PhAdvice around: (PhPointcut receivers: self classpattern selectors: #new context: #(proceed) )
			send: #instantiate: to: self).
	self install.
]

{ #category : #installing }
PhPerObjDeployAspect >> instantiate: aContext [
	| theObject theAspect|
	theObject := aContext proceed.
	theAspect := self aspectclass new.
	theAspect perform: self targetmethod with: theObject.
	theAspect init.  
	^theObject.
	
]

{ #category : #accessing }
PhPerObjDeployAspect >> targetmethod [
	^ targetmethod
]

{ #category : #accessing }
PhPerObjDeployAspect >> targetmethod: anObject [
	targetmethod := anObject
]
