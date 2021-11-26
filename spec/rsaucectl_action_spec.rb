describe Fastlane::Actions::RsaucectlAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The rsaucectl plugin is working!")

      Fastlane::Actions::RsaucectlAction.run(nil)
    end
  end
end
