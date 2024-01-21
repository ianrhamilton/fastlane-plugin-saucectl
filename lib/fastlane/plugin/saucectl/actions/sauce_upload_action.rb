require 'fastlane/action'
require 'json'
require 'yaml'
require_relative '../helper/api'

module Fastlane
  module Actions
    module SharedValues
      SAUCE_USERNAME = :SAUCE_USERNAME
      SAUCE_ACCESS_KEY = :SAUCE_ACCESS_KEY
    end

    class SauceUploadAction < Action
      @messages = YAML.load_file("#{__dir__}/../strings/messages.yml")

      def self.run(params)
        response = Fastlane::Saucectl::Api.new(params).upload
        body = JSON.parse(response.body)
        body['item']['id']
      end

      def self.description
        "Upload test artifacts to sauce labs storage"
      end

      def self.details
        "Upload test artifacts to sauce labs storage"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :platform,
                                       description: "application under test platform (ios or android)",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['platform_error']) if value.to_s.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :file,
                                       description: "File to upload to sauce storage",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['file_error']) unless value && !value.empty?
                                         if value
                                           UI.user_error!("Could not find file to upload \"#{value}\" ") unless File.exist?(value)
                                           extname = File.extname(value)
                                           UI.user_error!("Extension not supported for \"#{value}\" ") unless @messages['accepted_file_types'].include?(extname)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :app,
                                       description: "Name of the application to be uploaded",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['app_name_error']) unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :region,
                                       description: "Data Center region (us or eu), set using: region: 'eu'",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['region_error'].gsub!('$region', value)) unless @messages['supported_regions'].include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :sauce_username,
                                       env_name: "SAUCE_USERNAME",
                                       description: "Your sauce labs username in order to authenticate upload requests",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_USERNAME],
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['sauce_username_error']) unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :sauce_access_key,
                                       env_name: "SAUCE_ACCESS_KEY",
                                       description: "Your sauce labs access key in order to authenticate upload requests",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_ACCESS_KEY],
                                       optional: false,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['sauce_api_key_error']) unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_description,
                                       description: "A description of the artifact (optional, 1-255 chars)",
                                       optional: true,
                                       is_string: true,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['description_malformed']) unless value && !value.empty? && value.to_s.length < 256
                                       end)
        ]
      end

      def self.authors
        ["Ian Hamilton"]
      end

      def self.category
        :testing
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end

      def self.example_code
        [
          "sauce_upload({
                    platform: 'android',
                    sauce_username: 'username',
                    sauce_access_key: 'accessKey',
                    app: 'Android.MyCustomApp.apk',
                    file: 'app/build/outputs/apk/debug/app-debug.apk',
                    region: 'eu'
                  })",
          "sauce_upload({
                    platform: 'android',
                    sauce_username: 'username',
                    sauce_access_key: 'accessKey',
                    app: 'Android.MyCustomApp.apk',
                    file: 'app/build/outputs/apk/debug/app-debug.apk',
                    region: 'eu',
                    app_description: 'this is a test description'
                  })",
          "sauce_upload({
                    platform: 'ios',
                    sauce_username: 'username',
                    sauce_access_key: 'accessKey',
                    app: 'MyTestApp.ipa',
                    file: 'path/to/my/app/MyTestApp.ipa',
                    region: 'eu'
                  })"
        ]
      end

      def self.return_value
        "Returns the application id of the app uploaded"
      end
    end
  end
end
