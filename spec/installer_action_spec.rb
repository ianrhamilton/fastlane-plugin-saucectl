require_relative 'spec_helper'
require_relative '../spec/utils/mock_api'

describe Fastlane::Actions::InstallToolkitAction do
  describe "sauce labs installer action" do

    let(:action) { Fastlane::Actions::InstallToolkitAction }

    before do
      FileUtils.rm_r('.sauce') if Dir.exist?('.sauce')
      FileUtils.rm_r('bin') if Dir.exist?('bin')
      FileUtils.mkdir('bin')
    end

    after do
      FileUtils.rm_r('bin') if Dir.exist?('bin')
      FileUtils.rm_r('.sauce') if Dir.exist?('.sauce')
    end

    it 'should download saucectl binary' do
      Saucectl::MockApi.new.download
      installer = action.run
      expect(installer).to be_truthy
    end

    it 'should handle failed download of saucectl binary' do
      Saucectl::MockApi.new.failed_download
      expect { action.run }.to raise_error('❌ Failed to install saucectl binary: status code ["503", ""] after 30 seconds')
    end
  end
end
