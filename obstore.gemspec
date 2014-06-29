require './lib/obstore'

Gem::Specification.new do |gem|
  gem.name        = 'obstore'
  gem.license     = 'MIT'
  gem.version     = ObStore::VERSION
  gem.summary     = 'ObStore is a smart persistent Object store.'
  gem.description = "ObStore allows you to save any object to a file along with metadata about that object. You can also set an expiry for an object and ObStore will lazily delete the data for you."
  gem.authors     = ['Michael Heijmans']
  gem.email       = 'parabuzzle@gmail.com'
  gem.homepage    = 'https://github.com/parabuzzle/obstore'
  gem.files       = Dir.glob("lib/**/*")

  gem.add_development_dependency 'rspec', '~>3.0'
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ['lib']
end