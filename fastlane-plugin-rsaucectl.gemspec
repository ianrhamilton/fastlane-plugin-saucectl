lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/saucectl/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-saucectl'
  spec.version       = Fastlane::Saucectl::VERSION
  spec.author        = 'Ian Hamilton'
  spec.email         = 'ian.ross.hamilton@gmail.com'

  spec.summary       = 'Simplify the set up, configuration, upload, and execution of espresso and XCUITest on the Sauce Labs platform by utilizing fastlane which will enable you to test your iOS and Android apps at scale.'
  spec.homepage      = 'https://github.com/ianrhamilton/fastlane-plugin-saucectl'
  spec.license       = 'MIT'
  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('fastlane')
  spec.add_development_dependency('ox', '2.14.5')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rubocop', '1.12.1')
  spec.add_development_dependency('rubocop-performance')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('webmock')
end
