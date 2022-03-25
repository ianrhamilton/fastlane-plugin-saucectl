require 'fastlane/plugin/saucectl/version'

module Fastlane
  module Saucectl
    def self.all_classes
      Dir[File.expand_path('*/{actions,helper}/*.rb', File.dirname(__FILE__))]
    end
  end
end

# By default we want to import all available actions and helpers
# A plugin can contain any number of actions and plugins
Fastlane::Saucectl.all_classes.each do |current|
  require current
end
