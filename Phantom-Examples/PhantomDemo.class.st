Class {
	#name : #PhantomDemo,
	#superclass : #Object,
	#category : 'Phantom-Examples'
}

{ #category : #'as yet unclassified' }
PhantomDemo class >> clonableComparableHashableExample [
	| clonable hashable comparable |
	[| p1 p2 dict |
	"Transcript open."
	clonable := ClonablePointDemoAspect new.
	hashable := HashablePointDemoAspect new.
	comparable := ComparablePointDemoAspect new.
	
	clonable install.  
	hashable install.  
	comparable install.
	Transcript show: 'Clonable test'; cr.
	p1 := PhantomDemoPoint new.
	p1 setPolarWith: (Float pi) and: 1.0.
	p2 := p1 copy.
	Transcript show: 'p1: ', p1 asString; cr.
	Transcript show: 'p2: ', p2 asString; cr.
	p1 rotate: (Float pi / -2.0).
	Transcript show: 'p1: ', p1 asString; cr.
	Transcript show: 'p2: ', p2 asString; cr.
	Transcript show: 'Hashable test'; cr.
	p1 := PhantomDemoPoint new.
	p2 := PhantomDemoPoint new.
	p1 setRectangularWith: 10 and: 10.
	p2 setRectangularWith: 10 and: 10.
	dict := Dictionary newFrom: {p1 -> 'p1'}.
	Transcript show: 'p1: ', p1 asString; cr.
	Transcript show: 'p2: ', p2 asString; cr.
	Transcript show: 'p1: ', p1 hash asString; cr.
	Transcript show: 'p2: ', p2 hash asString; cr.
	Transcript show: ('Got: ', (dict at: p2) asString); cr.
	Transcript show: 'Comparable test'; cr.
	p1 := PhantomDemoPoint new.
	p2 := PhantomDemoPoint new.
	Transcript show: ('p1 =?= p2 : ', (p1 compareTo: p2) asString); cr.
	p1 setRectangularWith: 2 and: 5.
	p2 setRectangularWith: 2 and: 5.
	Transcript show: ('p1 =?= p2 : ', (p1 compareTo: p2) asString); cr.
	p2 setRectangularWith: 3 and: 6.
	Transcript show: ('p1 =?= p2 : ', (p1 compareTo: p2) asString); cr.
	 ] ensure: [
	clonable uninstall.
	hashable uninstall.
	comparable uninstall. ]
]

{ #category : #'as yet unclassified' }
PhantomDemo class >> getInfoExample [
	| pc adv asp |
	"Transcript open."
	Transcript show: 'Demo without aspect installed'; cr; cr.
	PhantomDemoClass go.
	pc := PhPointcut new
	receivers: 'PhantomDemoClass';
	localSelectors: #any asParser star;
	context: #(#receiver #arguments #proceed #selector).
	adv := PhAdvice new
		pointcut: pc;
		type: #around;
		advice: [:context |
			| result |
			Transcript show: 'Intercepted message: ', context selector asString; cr.
			Transcript show: 'in: ', context receiver class name asString; cr.
			Transcript show: 'parameters: ', context arguments asString; cr.
			Transcript show: 'Running original method:'; cr.
			 result := context proceed.
			Transcript show: 'result: ', result asString; cr.
			result].

		asp := PhAspect new.
		asp add: adv.
		[
		asp install. 
		Transcript show: 'Demo with installed aspect'; cr;cr.
		PhantomDemoClass go.
		] ensure: [asp uninstall]
]

{ #category : #'as yet unclassified' }
PhantomDemo class >> traceExample1 [
	| c1 c2 s1 asp |
	"Transcript open."
	PhantomDemoTrace tracelevel: 2.  
	PhantomDemoTrace initStream: (WriteStream on: '').  
	asp := TraceDemoAspect new.
	[asp install.
	c1 := PhantomDemoCircle x: 3.0 y: 3.0 r: 2.0.
	c2 := PhantomDemoCircle r: 4.0.
	s1 := PhantomDemoSquare x: 1.0 y: 2.0.
	Transcript show: 'c1 perimeter : ', (c1 perimeter asString); cr.
	Transcript show: 'c1 area : ', (c1 area asString); cr.
	Transcript show: 's1 perimeter : ', (s1 perimeter asString); cr.
	Transcript show: 's1 area : ', (s1 area asString); cr.
	Transcript show: 'c2 distance c1 : ', ((c2 distance: c1) asString); cr.
	Transcript show: 's1 distance c1 : ', ((s1 distance: c1) asString); cr.
	Transcript show: 's1 asString : ', (s1 asString); cr.
	Transcript show: asp trace traceStream contents.] ensure: [asp uninstall]  
]
