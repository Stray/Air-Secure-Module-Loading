/* AS3
	Copyright 2009 Newloop but feel free to use, reuse, recycle, edit and publish without restriction.
	
	Original basis for this code is 'XMLSignatureValidation' from ADOBE: http://www.adobe.com/devnet/air/flex/quickstart/xml_signatures.html
	
	Requires the mx.utils.Base64Decoder, Base64Encoder and SHA256 classes. Included with Flex. Use in flash requires the SignatureUtils.swc package, available from link above.
*/

package com.newloop.air.moduleloading {
	import flash.security.IURIDereferencer;
	import flash.security.ReferencesValidationSetting;
	import flash.security.RevocationCheckSettings;
	import flash.security.SignatureStatus;
	import flash.security.XMLSignatureValidator;
	import flash.utils.ByteArray;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;	
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import mx.utils.SHA256;
	
	import com.newloop.util.events.DebugEvent;
	
	
	
	/**
	 *  PackageSignatureCheck verifies whether the signature of a package (folder created by adt, or air package created in flash and renamed .zip) passed to 'validate' is or isn't a good match with the current air app's signing certificate 
	 *	
	 *	Dispatches 3 possible events: Error, Passed and Failed.
	 *	
	 *	USAGE: 
	 *	// instantiate
	 *	var mySignatureChecker:PackageSignatureCheck = new PackageSignatureCheck();
	 *	// add some event listeners
	 *	mySignatureChecker.addEventListener(PackageSignatureCheck.PACKAGE_SIGNATURE_PASSED, this.signatureCheckPassedHandler);
	 *	mySignatureChecker.addEventListener(PackageSignatureCheck.PACKAGE_SIGNATURE_FAILED, this.signatureCheckFailedHandler);
	 *	mySignatureChecker.addEventListener(PackageSignatureCheck.PACKAGE_SIGNATURE_ERROR, this.signatureCheckErrorHandler); 
	 *	// process your file - must be in the application storage directory
	 *	mySignatureChecker.validate(packageToValidate);
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 9.0.0
	 *
	 *	@author Lindsey Fallow
	 *	@since  02.09.2009
	 */
	 public class PackageSignatureCheck extends EventDispatcher {
		
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		public static const PACKAGE_SIGNATURE_PASSED:String = "packageSignaturePassed";
		public static const PACKAGE_SIGNATURE_FAILED:String = "packageSignatureFailed";
		public static const PACKAGE_SIGNATURE_ERROR:String = "packageSignatureError";
		public static const READY:String = "ready";
		public static const STATUS_NOT_READY:String = "statusNotReady";
		public static const STATUS_READY:String = "statusReady";
		
		private const signatureNS:Namespace = new Namespace("http://www.w3.org/2000/09/xmldsig#");
		
	    //--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		public function PackageSignatureCheck():void{
			trace("PackageSignatureCheck instantiated");
		    this.status = PackageSignatureCheck.STATUS_NOT_READY;
		}
	
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
	
		// the actual air application's own signature certificate
		private var ownCertificate:ByteArray;
		
		// the signature, document and file being processed
		private var xmlSignature:XML;
		private var xmlDocument:XML;
		private var signatureFile:File;
	
		// have we finished getting our own certificate? Are we midway through another file operation
		// VERY IMPORTANT: Opening 2 fileStreams simultaneously caused Kernel Crash in OS X 10.6
		private var status:String;
			
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		public function getStatus():String{
			return this.status;
		}
		 
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		
		
		public function initialise():void{
			this.findOwnCertificate();
		}
		
		public function validate(packageFolderName:String):void{
			if(this.status == PackageSignatureCheck.STATUS_READY){
				this.validatePackage(packageFolderName);
			}
		}
        
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------

		private function signatureVerificationCompleteHandler(event:Event):void{
		    
			var validator:XMLSignatureValidator = event.target as XMLSignatureValidator;  
			
			this.checkVerificationStatusAndManifest(validator);
						   
		}
		
		private function signatureVerificationErrorHandler(event:ErrorEvent):void{
			// dispatch an error event - because we're looking for paranoia here, we don't much care what caused the error
			this.dispatchSignatureErrorEvent(event.text); 			
		}
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
		
		private function validatePackage(packageFolderName:String):void{
			this.status = PackageSignatureCheck.STATUS_NOT_READY;
		    
			
			var pathToSignature:String = packageFolderName + "/META-INF/signatures.xml";
			
			// we're restricting this to the application storage directory, so only content downloaded by this application can be loaded this way
			try{
				this.signatureFile = File.applicationStorageDirectory.resolvePath(pathToSignature);
				this.dispatchDebugEvent("Resolved path to signature");
			} catch (e:Error) {
				//
				this.dispatchSignatureErrorEvent("Could not resolve path to signature. PackageSignatureCheck: Line 79");
			}			
						
			// the XMLSignatureValidator class is in the SignatureUtils.swc package
			var verifier:XMLSignatureValidator = new XMLSignatureValidator();
			verifier.addEventListener(Event.COMPLETE, this.signatureVerificationCompleteHandler);
			verifier.addEventListener(ErrorEvent.ERROR, this.signatureVerificationErrorHandler);
			
		   
			this.xmlDocument = this.loadFile(this.signatureFile);
			this.xmlSignature = this.extractSignature(this.xmlDocument);
			
			try{
				
				//Set the validation options
				verifier.useSystemTrustStore = false;
				verifier.addCertificate(this.ownCertificate, true);
				verifier.referencesValidationSetting = ReferencesValidationSetting.VALID_OR_UNKNOWN_IDENTITY;
				verifier.revocationCheckSetting = RevocationCheckSettings.BEST_EFFORT;
				
				//Setup the dereferencer
				var dereferencer:IURIDereferencer = new LimitedSignatureDereferencer(this.xmlDocument);
				verifier.uriDereferencer = dereferencer;
				
				//Validate the signature
				verifier.verify(this.xmlSignature);
		
			} catch (e:Error){
				// dispatch an error event - because we're looking for paranoia here, we don't much care what caused the error
				this.dispatchSignatureErrorEvent("Verification encountered a problem. PackageSignatureCheck: Line 106");
			}
		}
		
		private function getCertificateFromSignature(xmlSig:XML):ByteArray{
			this.dispatchDebugEvent("getCertificateFromSignature");
			
			try{
				var decoder:Base64Decoder = new Base64Decoder();
				decoder.decode(xmlSig..signatureNS::X509Certificate);
				var certificate:ByteArray = decoder.toByteArray();
				this.dispatchDebugEvent("Obtained certificate ByteArray.");
				return certificate;
			} catch (e:Error){
			   	// dispatch an error event - because we're looking for paranoia here, we don't much care what caused the error
				this.dispatchSignatureErrorEvent("Unable to obtain certificate from signature. PackageSignatureCheck: Line 118");
				
			}
			return null;
		}
		
		
		
		private function checkVerificationStatusAndManifest(validator:XMLSignatureValidator):void{
			
			//check certificate was ok
			if( validator.identityStatus != SignatureStatus.VALID ){
				this.dispatchSignatureFailedEvent();
				return;
			}
			
			//check the references
			if( validator.referencesStatus != SignatureStatus.VALID ){
				this.dispatchSignatureFailedEvent();
				return;
			}
			
			// certificate and references are both ok, 	check the manifest
			var manifest:XMLList = this.xmlSignature.signatureNS::Object.signatureNS::Manifest;
			if( manifest.length() > 0 ){
				if(this.verifyManifest( manifest, this.signatureFile )){
					this.dispatchSignaturePassedEvent();
					return;
				}
			}
			
			// we're paranoid, so default to failure
			this.dispatchSignatureFailedEvent();
		}
		
		
		private function verifyManifest( manifest:XMLList, sigFile:File ):Boolean
		{
			var result:Boolean = true;
			var nameSpace:Namespace = manifest.namespace();
			
			if( manifest.nameSpace::Reference.length() <= 0 ) {
				result = false;
			}                                                 
			
			for each (var reference:XML in manifest.nameSpace::Reference) {
				var file:File = sigFile.parent.parent.resolvePath(reference.@URI);
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				var fileData:ByteArray = new ByteArray();
				stream.readBytes( fileData, 0, stream.bytesAvailable );
		
				var digestHexString:String = SHA256.computeDigest( fileData );
				var digest:ByteArray = new ByteArray();
				for( var c:int = 0; c < digestHexString.length; c += 2 ){
					var byteChar:String = digestHexString.charAt(c) + digestHexString.charAt(c+1);
					digest.writeByte( parseInt( byteChar, 16 ));
				}
				digest.position = 0;
				
				var base64Encoder:Base64Encoder = new Base64Encoder();
				base64Encoder.insertNewLines = false;
				base64Encoder.encodeBytes( digest, 0, digest.bytesAvailable );
				var digestBase64:String = base64Encoder.toString();
				if( digestBase64 == reference.nameSpace::DigestValue )
				{
					result = result && true;
				} 
				else 
				{
					result = false;
				}
				base64Encoder.reset();
			}

			return result;
		}
					
	   
		
		private function findOwnCertificate():void{
			this.dispatchDebugEvent("Running findOwnCertificate");
			
			try {
				// this is the standard path for the signature in an air package
				var ownSignature:File = File.applicationDirectory.resolvePath("META-INF/signatures.xml");
				var xmlDoc:XML = this.loadFile(ownSignature);
				var xmlSig:XML = this.extractSignature(xmlDoc);
				// store a copy of this certificate - we'll need this for verfication			
				this.ownCertificate = this.getCertificateFromSignature(xmlSig);
				this.dispatchDebugEvent("Obtained own certificate");
				this.status = PackageSignatureCheck.STATUS_READY;
				this.dispatchEvent(new Event(PackageSignatureCheck.READY));
				
			} catch(e:Error){
				this.dispatchSignatureErrorEvent("Unable to obtain own signature. PackageSignatureCheck: findOwnCertificate"); 
			} 
			
			//this.validatePackage();
			
		}
		
		
		private function loadFile(sigFile:File):XML{
			this.dispatchDebugEvent("Loading signature file: " + sigFile.url);  
			
			try {
				var sigFileStream:FileStream = new FileStream();
				sigFileStream.open(sigFile, FileMode.READ);
				var fileContents:String = sigFileStream.readUTFBytes(sigFileStream.bytesAvailable);
				sigFileStream.close();
				var xmlDoc:XML = new XML( fileContents );
			
				return xmlDoc;    
		 	} catch(e:Error){
				this.dispatchSignatureErrorEvent("Unable to load signature file. PackageSignatureCheck: loadFile");
			    return null;
			}
			
			return null;
		}
		
		private function extractSignature(xmlDoc:XML):XML{
			this.dispatchDebugEvent("extracting signature file"); 
			var signatureList:XMLList = xmlDoc..signatureNS::Signature;
			if( signatureList.length() > 0 ){
				var xmlSig:XML = XML( signatureList[signatureList.length()-1] );
			} else {
				// dispatch an error event - because we're looking for paranoia here, we don't much care what caused the error
				this.dispatchSignatureErrorEvent("Signature list missing. PackageSignatureCheck: extractSignature");
			}
			
			return xmlSig;
		}
		
		//--------------------------------------
		//  EVENT DISPATCHING
		//--------------------------------------
		
		
		private function dispatchDebugEvent(debugMessage:String):void{
			var e:DebugEvent = new DebugEvent(DebugEvent.DEBUG_MESSAGE, debugMessage);
			this.dispatchEvent(e);
		}
		
		private function dispatchSignaturePassedEvent():void{
			this.dispatchEvent(new Event(PackageSignatureCheck.PACKAGE_SIGNATURE_PASSED));
			this.status = PackageSignatureCheck.STATUS_READY;
			
		}
		
		private function dispatchSignatureFailedEvent():void{
			this.dispatchEvent(new Event(PackageSignatureCheck.PACKAGE_SIGNATURE_FAILED));
			this.status = PackageSignatureCheck.STATUS_READY;
			
		}
		
		private function dispatchSignatureErrorEvent(errorMsg:String = ""):void{
			 this.dispatchEvent(new ErrorEvent(PackageSignatureCheck.PACKAGE_SIGNATURE_ERROR,false, false, errorMsg)); 
		}
		
		
		
	}
}