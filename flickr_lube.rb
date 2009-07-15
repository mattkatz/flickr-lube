#!/usr/bin/ruby
#stick yours in here.
username = 'YOUR_FLICKR_USERNAME'
begin
  require 'rubygems'
rescue LoadError
  puts "Flickr Lube needs RubyGems installed on your server to continue, and we can't find it."
  puts 'See http://rubygems.org for installation instructions'
  exit
end
begin 
  gemnames = ['fleakr']
  gemnames.each do |gname|
	require gname
  end
rescue LoadError
  puts "Flickr Lube uses Fleakr to get things greased up. Try 'sudo gem install fleakr' and then put some nice music on."
  puts "If your system doesn't let you sudo, http://rubygems.org/read/chapter/3#page83 has instructions on getting around that.  This will be worth it." 
  puts "Do you want this script to try to install the gems for you? (y/n):"
  if gets.chomp.downcase == 'y' 
    require 'rubygems/dependency_installer'
    installer = Gem::DependencyInstaller.new
    gemnames.push 'builder'
    gemnames.each do |gname|
      installer.install(gname) 
    end
  end
  puts "If everything installed fine, you should be able to run the script now"
  exit
end
#if this stops working, no prob.  Go here:
#http://www.flickr.com/services/api/keys/apply/
#get a new key, put it right here
Fleakr.api_key = 'ff49d13c700dc4942fd7bdfe6f24ab61'
def process_photos(photos,dir,title,description,size,photo_ids_to_exclude)
  puts "processing " + title
  processed_ids = []
  images = {}
  info = {}
  info['directory'] = {'title' => title, 'description' => description}
  FileUtils.mkdir(dir) unless File.exist?(dir)
  template = "%0#{photos.length.to_s.length}d_"
  photos.each_with_index do |photo, index|
    next if photo_ids_to_exclude.include?(photo.id)
    puts "processing " + photo.title
    image = photo.send(size)
    unless image.nil?
      prefix = sprintf(template,(index+1))
      image.save_to(dir,prefix)
      images[prefix+image.filename] = {'title' => photo.title, 'desc' => photo.description.gsub("\n",'<br/>')}
      processed_ids.push(photo.id)
    end
  end
  info['images'] = images
  File.open(dir+'/info.yml', 'w') do | file|
    YAML.dump(info, file)
  end
  processed_ids
end


# Find a user
user = Fleakr.user(username)
photos_in_sets = []
# save each set to a folder 
user.sets.each do | set|
  photos_in_sets += process_photos(set.photos,"./data/"+set.title,set.title,set.description,:large,photos_in_sets)
end
puts "processing photos not in sets"

# save each photo to this folder
process_photos(user.photos,"./data/From Flickr","Main Photos","pulled out of flickr",:large,photos_in_sets)
