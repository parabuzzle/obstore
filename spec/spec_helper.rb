# This file is loaded before rspec tests are run
require 'simplecov'
require 'simplecov-rcov'
require 'coveralls'

SimpleCov.start do
  add_filter '/spec/'
  add_group 'lib', 'lib'
  #SimpleCov.minimum_coverage 75
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::RcovFormatter
  ]
end if ENV["COVERAGE"]

Coveralls.wear!
