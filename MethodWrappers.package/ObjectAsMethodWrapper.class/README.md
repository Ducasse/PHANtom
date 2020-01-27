This class implements methodWrapper like behavior using the trick that the VM allows any object to be put in a method dictionary if it implements the run:with:in: method.

Here is a way to install a methodWrapper.

((RPackageOrganizer default packageNamed: 'BlueInk-Core') classes gather: [ :each | ObjectAsOneTimeMethodWrapper installOnClass: each ]) inspect

((RPackageOrganizer default packageNamed: 'BlueInk-Core') classes 
	do: [:each| ObjectAsMethodWrapper uninstallClass: each ]) 


Possible improvements:
	- it is not clear that specifying pre and post action is better than a simple method as in the original MethodWrapper implementation. 

Questions: 
	- what is reference vs oldMethod (I would prefer to call it original method, spiedMethod)
	- I do not think that we need to have a RGMethodDefinition since we have all the information in the compiled method now. 