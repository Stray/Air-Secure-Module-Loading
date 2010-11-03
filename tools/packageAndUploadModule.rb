require 'net/ftp'

# configure these to suit your settings   

# the folder where your modules should be uploaded to, relative to the root of your ftp
module_remote_folder = '/public_html/module_resources'

remote_ftp = 'your server url'
ftp_username = 'username'
ftp_password = 'password'

# the directory that contains your compiled modules, inside their own folders
module_local_parent_directory = 'bin/modules/'

# a placeholder in the SomeModule-app.xml file, to be replaced with the version number 
version_placeholder = '$versionNumber'

# args you passed  eg 'menu_module' 07

# the script expects to find menu_module/MenuModule.swf and menu_module/MenuModule-app.xml files to work with.

module_name = ARGV[0]

version_number = ARGV[1]   

# let's do it!

puts 'upload module running'

puts 'processing: ' + module_name

puts 'to version number ' + version_number.to_s

target_directory_path = module_local_parent_directory + module_name

puts 'targeting directory: ' + target_directory_path

version_directory_name = module_name + "_" + version_number

version_directory_path = target_directory_path + "/" + version_directory_name

current_directory = Dir.pwd

puts 'current directory: ' + current_directory

puts 'creating version directory: ' + version_directory_path

base_swf_file_name = ''

Dir.chdir(target_directory_path)

target_directory = Dir.pwd

# look for the app descriptor

# look for the target swf

Dir.mkdir(version_directory_name)

Dir.foreach(target_directory) do |entry|
  
  file_extension = entry.split(/\./).pop

  unless(file_extension.nil?)
  
    if(file_extension == 'xml')
      
      puts 'found the application descriptor: ' + entry

      new_app_descriptor_file_name = entry.split(/\-/)[0]
      new_app_descriptor_file_name = new_app_descriptor_file_name + "_" + version_number.to_s + "-app.xml" 
      
      new_app_descriptor_file = File.new(version_directory_name + "/" + new_app_descriptor_file_name, "w");
      
      base_app_descriptor_file = File.open(entry, "r");
      
      base_app_descriptor_file.each do |line|
         line = line.gsub(version_placeholder, version_number.to_s)
         new_app_descriptor_file.write(line)  
      end
      
      new_app_descriptor_file.close
      base_app_descriptor_file.close 
      
    elsif(file_extension == 'swf')
      
      puts 'found the swf file: ' + entry
      
      base_swf_file_name = entry.split(/\./)[0]
      base_swf_file_name = base_swf_file_name + "_" + version_number.to_s
      new_swf_file_name = base_swf_file_name + ".swf" 
      
      new_swf_file = File.new(version_directory_name + "/" + new_swf_file_name, "w");
      
      base_swf_file = File.open(entry, "r");
      
      base_swf_file.each do |line|
         new_swf_file.write(line)  
      end
      
      new_swf_file.close
      base_swf_file.close
    
    end
    
  end
end

puts 'bundle the air module zip file'

module_build_file_name = base_swf_file_name + '.zip'

Dir.chdir(version_directory_name)

# edit this line to have your real certificate details

result_of_module_build = `adt -package -storetype pkcs12 -storepass goodpw -keystore /loopShop/as3_classes/assets/tests/air_plugin_system/certificates/goodCert.p12 -keypass goodpw "#{module_build_file_name}" "#{base_swf_file_name}-app.xml" .`

puts result_of_module_build

puts 'ftp the zip file to the server'

ftp = Net::FTP.new(remote_ftp)
ftp.passive = true
ftp.login ftp_username, ftp_password

ftp.chdir(module_remote_folder)

fileupload_count = 0

ftp.putbinaryfile(module_build_file_name, module_build_file_name, 100000) do |block|
  fileupload_count += 100000
  puts "#{fileupload_count} bytes uploaded"
end

ftp.close

puts 'all done'