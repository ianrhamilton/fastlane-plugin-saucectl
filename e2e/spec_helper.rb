$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/saucectl' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)
