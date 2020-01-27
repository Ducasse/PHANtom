Class {
	#name : #PhMembraneExample,
	#superclass : #Object,
	#category : 'Phantom-Examples-Membranes'
}

{ #category : #'as yet unclassified' }
PhMembraneExample class >> adviseBaseComputationExample [
	| advisingMembrane baseMembrane asp |
	[baseMembrane := PhMembrane new
		pointcut: (PhPointcut new
			receivers: 'PhBaseExample';
			selectors: 'foo').
	advisingMembrane := PhMembrane new	advise: baseMembrane.
	baseMembrane install.
	"advisingMembrane install."
	asp := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhBaseExample';
				selectors: 'bar');
			advice: ['foo'];
			type: #around).
	asp registerOn: advisingMembrane.
	Transcript show: 'Calling bar directly...'; cr.
	Transcript show: (PhBaseExample new bar); cr.
	Transcript show: 'Calling bar from foo computation..'; cr.
	Transcript show: (PhBaseExample new foo); cr] ensure: [baseMembrane uninstall. "advisingMembrane uninstall"]  
	
	
]

{ #category : #'as yet unclassified' }
PhMembraneExample class >> crosscuttingMembranes [
	| cacheMembrane logMembrane cacheAsp logAsp pc |
	[ 
	pc := (PhPointcut new)
		receivers: 'PhBrowserExample+';
		selectors: 'get:';
		context: #(#arguments #receiver).
	cacheAsp := PhAspect new
		add:
			((PhAdvice new)
				pointcut: pc;
				advice: [ :context | 'cached: ' , context arguments asString ];
				type: #around).
	logAsp := PhAspect new
		add:
			((PhAdvice new)
				pointcut: pc;
				advice: [ :context | 
							Transcript
								show: (context receiver asString) , 'search: ' ,( context arguments asString);
								cr ];
				type: #after).
	cacheMembrane := PhMembrane new
		pointcut:
			((PhPointcut new)
				receivers: #('PhAdminBrowserExample' 'PhUserBrowserExample');
				selectors: 'get:').
	logMembrane := PhMembrane new
		pointcut:
			((PhPointcut new)
				receivers: #('PhGuestBrowserExample' 'PhUserBrowserExample');
				selectors: 'get:').
	cacheAsp registerOn: cacheMembrane.
	logAsp registerOn: logMembrane.
	logMembrane install.
	cacheMembrane install.
	Transcript
		show: 'User';
		cr.
	Transcript
		show: (PhUserBrowserExample new get: 'aUrl');
		cr.
	Transcript
		show: 'Admin';
		cr.
	Transcript
		show: (PhAdminBrowserExample new get: 'aUrl');
		cr.
	Transcript
		show: 'Guest';
		cr.
	Transcript
		show: (PhGuestBrowserExample new get: 'aUrl');
		cr ]
		ensure: [ 
			logMembrane uninstall.
			cacheMembrane uninstall ]
]

{ #category : #'as yet unclassified' }
PhMembraneExample class >> graphExample [
	| l0 l1 l2 cache quota |
	[l0 := PhMembrane new pointcut: (
		PhPointcut new
			receivers: 'PhBrowserExample+';
			selectors: 'browse').
	l1 := PhMembrane new advise: l0.
	l2 := PhMembrane new advise: l0.
	l2 advise: l1.
	cache := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhBrowserExample+';
				selectors: 'getUrl:');
			advice: [Transcript show: 'Cache';cr.
					PhDiskAccessorExample new accessDisk];
			type: #before).
	quota := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhDiskAccessorExample';
				selectors: 'accessDisk');
			advice: [Transcript show: 'Quota';cr];
			type: #before).
	cache registerOn: l1.
	quota registerOn: l2.
	l0 install.
	PhBrowserExample new browse.] ensure: [l0 uninstall.]
	    
]

{ #category : #'as yet unclassified' }
PhMembraneExample class >> reentrancyExample [
	| asp |
	[ 
	asp := PhAspect new
		add:
			((PhAdvice new)
				pointcut:
						((PhPointcut new)
								receivers: Transcript class asString;
								selectors: 'show:');
				advice: [ Transcript show: 'Showing: ' ];
				type: #before).
	asp install.
	Transcript show: 'Reentrancy'; cr. ] ensure: [ asp uninstall ]
]

{ #category : #'as yet unclassified' }
PhMembraneExample class >> towerExample [
	| l0 l1 l2 cache quota |
	[l0 := PhMembrane new pointcut: (
		PhPointcut new
			receivers: 'PhBrowserExample+';
			selectors: 'browse').
	l1 := PhMembrane new advise: l0.
	l2 := PhMembrane new advise: l1.
	cache := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhBrowserExample+';
				selectors: 'getUrl:');
			advice: [Transcript show: 'Cache';cr.
					PhDiskAccessorExample new accessDisk];
			type: #before).
	quota := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhDiskAccessorExample';
				selectors: 'accessDisk');
			advice: [Transcript show: 'Quota';cr];
			type: #before).
	cache registerOn: l1.
	quota registerOn: l2.
	l0 install.
	PhBrowserExample new browse.] ensure: [l0 uninstall.]
	    
]

{ #category : #'as yet unclassified' }
PhMembraneExample class >> treeExample [
	| l0 l1 l2 l3 cache quota |
	[l0 := PhMembrane new pointcut: (
		PhPointcut new
			receivers: 'PhBrowserExample+';
			selectors: 'browse').
	l1 := PhMembrane new advise: l0.
	l2 := PhMembrane new advise: l1.
	l3 := PhMembrane new advise: l0.  
	cache := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhBrowserExample+';
				selectors: 'getUrl:');
			advice: [Transcript show: 'Cache';cr.
					PhDiskAccessorExample new accessDisk];
			type: #before).
	quota := PhAspect new
		add: (PhAdvice new
			pointcut: (PhPointcut new
				receivers: 'PhDiskAccessorExample';
				selectors: 'accessDisk');
			advice: [Transcript show: 'Quota';cr];
			type: #before).
	cache registerOn: l1.
	quota registerOn: l2.
	quota registerOn: l3.  
	l0 install.
	PhBrowserExample new browse.] ensure: [l0 uninstall.]
	    
]
