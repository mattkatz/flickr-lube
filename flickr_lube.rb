#!/usr/bin/ruby
require 'rubygems'
require 'fleakr'
username = 'snarkhunt'
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
      images[prefix+image.filename] = {'title' => photo.title, 'desc' => photo.description}
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
user = Fleakr.user('snarkhunt')
photos_in_sets = []
# save each set to a folder 
user.sets.each do | set|
  photos_in_sets += process_photos(set.photos,"./data/"+set.title,set.title,set.description,:large,photos_in_sets)
end
puts "processing photos not in sets"

# save each photo to this folder
process_photos(user.photos,"./data/From Flickr","Main Photos","pulled out of flickr",:large,photos_in_sets)
