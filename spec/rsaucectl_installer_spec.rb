require_relative 'spec_helper'
require_relative 'utils/mock_api'

describe Fastlane::Saucectl::Installer do
  before do
    FileUtils.mkdir('bin')
  end

  after do
    FileUtils.rmdir('.sauce')
  end

  describe 'installer' do
    it 'should download saucectl binary' do
      Saucectl::MockApi.new.download
      installer = Fastlane::Saucectl::Installer.install
      expect(installer).to be_truthy
    end
  end
end
