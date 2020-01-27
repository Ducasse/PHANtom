Class {
	#name : #PhBrowserExample,
	#superclass : #Object,
	#category : 'Phantom-Examples-Membranes'
}

{ #category : #'as yet unclassified' }
PhBrowserExample >> browse [
	self getUrl: 'http://test.url'.
	PhDiskAccessorExample new accessDisk.
]

{ #category : #'as yet unclassified' }
PhBrowserExample >> get: aUrl [
	^ 'theUrlContent'
]

{ #category : #'as yet unclassified' }
PhBrowserExample >> getUrl: aUrl [
	Transcript show: 'Url';cr.
]
