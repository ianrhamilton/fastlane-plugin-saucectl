require_relative 'spec_helper'
require_relative 'utils/mock_api'

describe Fastlane::Saucectl::Installer do
  describe 'installer' do
    it 'should download saucectl binary' do
      mock = Saucectl::MockApi.new
      mock.download
      installer = Fastlane::Saucectl::Installer.install
      expect(installer).to be_truthy
    end
  end
end
