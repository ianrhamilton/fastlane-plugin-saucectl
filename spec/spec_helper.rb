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

require 'webmock/rspec'
require 'webmock/api'
require 'fastlane' # to import the Action super class
require 'fastlane/plugin/rsaucectl' # import the actual plugin

include WebMock::API

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

def default_header
  {
    'Accept' => '*/*',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Authorization' => /(.*)/,
    'Host' => 'api.eu-central-1.saucelabs.com',
    'User-Agent' => 'Ruby'
  }
end

def delete_header
  {
    'Accept' => '*/*',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Authorization' => /(.*)/,
    'User-Agent' => 'Ruby'
  }
end

def upload_header
  {
    'Accept' => '*/*',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Authorization' => /(.*)/,
    'Content-Type' => 'multipart/form-data',
    'Host' => 'api.eu-central-1.saucelabs.com',
    'User-Agent' => 'Ruby'
  }
end

def install_header
  {
    'Accept' => '*/*',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Host' => 'saucelabs.github.io',
    'User-Agent' => 'Ruby'
  }
end

def create(file)
  origin_folder = File.expand_path("..", __dir__)
  FileUtils.cp(File.new("#{__dir__}/utils/#{file}"), origin_folder)
  YAML.load_file("#{origin_folder}/#{file}")
end

def delete(file)
  origin_folder = File.expand_path("..", __dir__)
  FileUtils.rm(File.new("#{origin_folder}/#{file}")) if File.exist?("#{origin_folder}/#{file}")
end
