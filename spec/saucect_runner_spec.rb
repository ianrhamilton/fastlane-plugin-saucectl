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
      config = {}
      config[:timeout_in_minutes] = 30
      expect {  Fastlane::Saucectl::Runner.new(config).execute }.to raise_error(/❌ sauce labs executable file does not exist! Expected sauce executable file to be located at:/)
    end
  end
end
