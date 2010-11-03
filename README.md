**A framework for securely loading 'modules' (swfs) into Air apps.**

* Modules with matching signatures are loaded to the app sandbox (if requested). 
* Modules without matching signatures requesting app sandbox loading are rejected.
* Modules can also be loaded to the non-application sandbox.

Interested?  [Read more here.](http://flair-flash-flex-air.blogspot.com/2009/09/framework-for-modular-air-applications.html)


**What's in the tools folder?**

A benefit of modular development is that you can do frequent releases - but packaging up swfs to signed zips, and uploading them to your server, can be a bit time consuming, so there's a script in there that automates those steps, and an example -app descriptor file that is set up for the version numbering to change.

I still like to update the required version number manually - it allows me to push up a new set of modules and release them together, or to a group of 'beta' users ahead of releasing to everybody.      