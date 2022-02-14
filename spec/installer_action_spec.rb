# require_relative "spec_helper"
require_relative '../spec/utils/mock_api'

describe Fastlane::Actions::InstallToolkitAction do
  describe "sauce labs installer action" do

    let(:action) { Fastlane::Actions::InstallToolkitAction }

    before do
      FileUtils.mkdir('bin')
      Saucectl::MockApi.new.download
    end

    after do
      FileUtils.rmdir('.sauce')
    end

    it 'should download saucectl binary' do
      installer = action.run
      expect(installer).to be_truthy
    end
  end
end
