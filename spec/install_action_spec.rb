require_relative "spec_helper"
require_relative "../lib/fastlane/plugin/rsaucectl/actions/rsaucectl_action"
require_relative 'utils/mock_api'

describe Fastlane::Actions::InstallAction do
  before do
    FileUtils.mkdir('bin')
  end

  after do
    FileUtils.rmdir('.sauce')
  end

  describe "rsaucectl" do
    it "should install action" do
       Saucectl::MockApi.new.download
       Fastlane::Actions::InstallAction.run
    end
  end
end
