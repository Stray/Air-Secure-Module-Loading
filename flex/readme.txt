Flex based version, October 30 2009, tested under Windows Vista, with Flex Builder Pro - 3.4 SDK.

Changes from the original Flash-based package from Newloop.
- this package will work for Flex modules (not tested for Flash modules)
- load of remote module into the app security sandbox only. Wasn't able to find a way to 
  load the remote module into the remote security sandbox. See links at the bottom of ModuleLoader.as
- added ForceInstall property in the remote module xml description (NOT FULLY IMPLEMENTED). This will allow 
  a remote module to be installed regardless of whether a similar odule already exists locally.
- removed references to Yahoo astra since Flex has all the UI components needed
- added MIT license to all files
- enhanced debug support, added Datagrid to UI
- removed restriction on file type for remote module Air digest files


Step by step process to run the application:
1) unzip the file
2) install the remoteModuleTester air package (double click on the Air file). There is no Air runtime installer so you must have the 
   Air runtime already installed.
3) copy the moduleA.zip file under /server into your server root folder
4) edit the modA.xml file to modify the moduleResourcePath_fp property to point to the moduleA.zip file on your server
5) run the air application installed in 2)
6) when prompted, select the modA.xml file on your local drive
7) at this point you should see in the DataGrid the whole process of download and validation of your remote module
8) Click in the Combo to test the module.

To regenerate the module air package:
A) Modify your moduleA.mxml file
B) Do Project>clean in Flex Builder 3. The moduleA.swf is output in the root folder 
   - you can change it in Project>Properties>Flex build path
C) Use the following command (Windows version, assuming your root server 
folder is d:\apache\htdocs) from the folder where you unzipped the package file (in step 1):

adt -package -storetype pkcs12 -keystore mycertificate.p12 D:\apache\htdocs\moduleA.zip ModuleA-app.xml -C d:\apache\htdocs\ModuleA.swf

If the adt command is not found, search for a file named adt in the Flex install folder tree, make sure 
this is in the path for your command line process.

When prompted, use mypassword as the password to sign the module package.

D) you should find the updated moduleA.zip file in your root folder, ready to be picked up by your Air app.

Make sure that in the properties of the remoteModuleTester project under module, 
ModuleA.mxml is there AND when you edit the module options, the "Do not optimize 
(module can be loaded by multiple location)" option is selected.

