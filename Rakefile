require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do
  # put any setup here that you may need...
end

task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task["spec"].execute
end

# Run the tests and build a test package by default
task :default => ['clean','spec','gem:build']

task :test => [:clean, :spec] do
  sh 'bundle exec rspec --format RspecJunitFormatter  --out ./spec_results.xml'
end

task :clean => ['gem:clean'] do
  sh 'rm -rf ./spec_results.xml'
  sh 'rm -rf ./coverage'
  sh 'rm -rf ./tmp'
end

task :deps do
  sh 'bundle install'
end

task :gem => ['gem:install']

namespace :gem do

  task :clean do
    sh "rm -rf *.gem"
  end

  task :build do
    sh "gem build ./*.gemspec"
  end

  task :install => [:clean, :build] do
    sh "gem install ./*.gem"
  end

end
