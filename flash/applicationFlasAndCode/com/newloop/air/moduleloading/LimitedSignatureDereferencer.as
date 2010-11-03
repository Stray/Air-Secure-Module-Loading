
// Original basis for this code is 'XMLSignatureValidation' from ADOBE: http://www.adobe.com/devnet/air/flex/quickstart/xml_signatures.html 

package com.newloop.air.moduleloading
{
	import flash.security.IURIDereferencer;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	/**
	 * Validates an AIR application signature, taking advantage of the fact that the SignedInfo 
	 * element always refers to an element with id="PackageContents".
	 */
	public class LimitedSignatureDereferencer implements IURIDereferencer {
		private const signatureNS:Namespace = new Namespace( "http://www.w3.org/2000/09/xmldsig#" );
		private var signedDocument:XML;
	
		public function LimitedSignatureDereferencer( signedDocument:XML ) {
			this.signedDocument = signedDocument;
		}
		
		public function dereference( uri:String ):IDataInput {
			var data:ByteArray = null;	
			try
			{	
				data = new ByteArray();
				if( uri.length == 0 ) {
					data.writeUTFBytes( signedDocument.toXMLString() );
					data.position = 0;					
				} else if( uri.match(/^#/) ) {
					var manifest:XMLList = signedDocument..signatureNS::Manifest.(@Id == uri.slice( 1, uri.length ));
					if (manifest.length() == 0){
						//try lower case id attribute
						manifest = signedDocument..signatureNS::Manifest.(@id == uri.slice( 1, uri.length ));
						if( manifest.length() == 0 ){
							//give up
							throw new Error("Manifest with matching id attribute not found.");
						}
					}
					data.writeUTFBytes( manifest.toXMLString() );
					data.position = 0;
				} else {
					throw( new Error("Unsupported signature type.") );
				}	
			}
			catch (e:Error) 
			{
				data = null;
				throw new Error("URI not resolvable: " + uri + ", " + e.message);
			} 
			finally 
			{
				return data;
			}
		}
	}
}