require_relative 'spec_helper'
require_relative 'utils/mock_api'
require_relative '../lib/fastlane/plugin/rsaucectl/helper/installer'

describe Fastlane::Saucectl::Installer do
  before do
    FileUtils.rm_r('bin') if Dir.exist?('bin')
    FileUtils.mkdir('bin')
  end

  after do
    FileUtils.rm_r('.sauce') if Dir.exist?('.sauce')
  end

  describe 'installer' do
    it 'should download saucectl binary' do
      Saucectl::MockApi.new.download
      installer = Fastlane::Saucectl::Installer.new.install
      expect(installer).to be_truthy
    end
  end
end
