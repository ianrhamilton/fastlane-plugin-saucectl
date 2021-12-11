$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  add_filter 'lib/helper/file_utils.rb'
end

if ENV['IS_CI']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'webmock/rspec'
require 'webmock/api'

include WebMock::API

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/rsaucectl' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)
