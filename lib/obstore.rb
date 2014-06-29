# This library allows you to persist objects with meta data
# ObStore supports data expiry and is designed with thread safety
#
# Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
# Copyright:: Copyright (c) 2014 Michael Heijmans
# License::   MIT

module ObStore

  # require library file that was passed
  def self.require_lib(lib)
    require lib
  end

  # iterates through the passed in array of
  # library paths and requires each of them
  def self.require_libs(libs)
    libs.each do |lib|
      self.require_lib(lib)
    end
  end

end

$:.concat [File.expand_path('../', __FILE__),File.expand_path('../obstore', __FILE__)]

# Require all ruby files in the obstore directory
ObStore.require_libs Dir.glob(File.expand_path('../obstore', __FILE__) + '/*.rb')