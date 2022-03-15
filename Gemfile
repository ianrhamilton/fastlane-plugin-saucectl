source('https://rubygems.org')

gem 'codecov', require: false, group: :test
gem 'rubocop-rspec', require: false, group: :test
gem 'simplecov', require: false, group: :test

gemspec

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
