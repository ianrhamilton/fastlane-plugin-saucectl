# require_relative 'spec_helper'
# require_relative '../lib/fastlane/plugin/rsaucectl/helper/saucectl_config'
#
# describe Fastlane::Saucectl::SaucectlConfigGenerator do
#   describe 'config generator' do
#     # before do
#     #   @config = create('config.yml')
#     #   create('fakePrivateCloudDevices.txt')
#     # end
#     #
#     # after do
#     #   delete('config.yml')
#     #   delete('fakePrivateCloudDevices.txt')
#     # end
#
#     it 'should create config.yml file based on user specified virtual device configurations' do
#       @config['test_distribution'] = 'package'
#       @config['is_virtual_device'] = true
#       @config['platform'] = 'android'
#       @config['kind'] = 'espresso'
#       File.open('config.yml', 'w') { |f| YAML.dump(@config, f) }
#
#       Saucectl::SaucectlConfigGenerator.new(@config).create
#       origin_folder = File.expand_path("../", "#{__dir__}")
#       assert(File.exist?("#{origin_folder}/.sauce/config.yml"))
#     end
#   end
# end
