Extension { #name : #Class }

{ #category : #'*MethodWrappers' }
Class >> unwrapAllMethods [
	^ObjectAsMethodWrapper uninstallClass: self
]

{ #category : #'*MethodWrappers' }
Class >> wrapAllMethods [
	^ObjectAsOneTimeMethodWrapper installOnClass: self
]

{ #category : #'*MethodWrappers' }
Class >> wrappedMethods [
	|someMethods|
	someMethods:= Set new.
	someMethods addAll: (self methodDictionary values select: [:e | e isKindOf: ObjectAsMethodWrapper ]).
	someMethods addAll: (self class  methodDictionary values select: [:e | e isKindOf: ObjectAsMethodWrapper ]).
	^someMethods
]
