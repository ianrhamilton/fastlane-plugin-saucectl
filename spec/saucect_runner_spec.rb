require 'fileutils'
require_relative 'spec_helper'
require_relative 'utils/mock_api'
require_relative '../lib/fastlane/plugin/rsaucectl/helper/runner'

describe Fastlane::Saucectl::Runner do

  before do
    FileUtils.rm('saucectl') if File.exist?('saucectl')
  end

  describe 'runner' do
    it 'should execute tests based on user specified config' do
      expect {  Fastlane::Saucectl::Runner.new.execute }.to raise_error(/❌ sauce labs executable file does not exist! Expected sauce executable file to be located at:/)
    end

    it 'should create a config' do
      # expect(Fastlane::Saucectl::Runner.new.execute).to receive(:execute).and_return(true)
      #
      # devices = [                          # Device(s) to run tests on
      #     {
      #       ios_model_id: 'iphonex',        # Device model ID, see gcloud command above
      #       ios_version_id: '11.2',         # iOS version ID, see gcloud command above
      #       orientation: 'portrait'         # Optional: default to portrait if not set
      #     },
      #     {
      #       ios_model_id: 'iphonexs',        # Device model ID, see gcloud command above
      #       ios_version_id: '12.3',         # iOS version ID, see gcloud command above
      #       orientation: 'portrait'         # Optional: default to portrait if not set
      #     }
      # ]
      #
      emulators = [                          # Device(s) to run tests on
        {
          name: "Android GoogleApi Emulator",        # Device model ID, see gcloud command above
          platformVersions: ['12.3'],         # iOS version ID, see gcloud command above
          orientation: 'portrait'         # Optional: default to portrait if not set
        }
      ]

      puts emulators[0][:name]
    end
  end
end
