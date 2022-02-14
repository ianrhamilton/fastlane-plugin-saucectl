lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/rsaucectl/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-rsaucectl'
  spec.version       = Fastlane::Rsaucectl::VERSION
  spec.author        = 'Ian Hamilton'
  spec.email         = 'ian.ross.hamilton@gmail.com'

  spec.summary       = 'Test your iOS and and Android apps at scale using Sauce Labs toolkit.'
  spec.homepage      = 'https://github.com/ianrhamilton/fastlane-plugin-rsaucectl'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/**/*.rb']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('fastlane', '>= 2.197.0')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rubocop', '1.12.1')
  spec.add_development_dependency('rubocop-performance')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('webmock')
end
