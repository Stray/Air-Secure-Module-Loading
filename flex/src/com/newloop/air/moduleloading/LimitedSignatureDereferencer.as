/* 
Copyright (c) <2009> <Newloop>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

// Original basis for this code is 'XMLSignatureValidation' from ADOBE: 
// http://www.adobe.com/devnet/air/flex/quickstart/xml_signatures.html 

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