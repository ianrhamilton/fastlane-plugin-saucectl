require 'fastlane/action'
require 'json'
require 'yaml'
require_relative '../helper/api'

module Fastlane
  module Actions
    class SauceAppsAction < Action
      @messages = YAML.load_file("#{__dir__}/../strings/messages.yml")
      def self.run(params)
        Fastlane::Saucectl::Api.new(config(params)).retrieve_all_apps
      end

      def self.config(params)
        {
          platform: params[:platform],
          app_name: params[:app_name],
          region: params[:region],
          sauce_username: params[:sauce_username],
          sauce_access_key: params[:sauce_access_key]
        }
      end

      def self.description
        "Returns the set of files by specific app id that have been uploaded to Sauce Storage by the requester"
      end

      def self.details
        "Returns the set of files by specific app id that have been uploaded to Sauce Storage by the requester"
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
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       description: "Name of your application under test",
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
                                       description: "Your sauce labs username in order to authenticate upload requests",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['sauce_username_error']) if value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :sauce_access_key,
                                       description: "Your sauce labs access key in order to authenticate upload requests",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['sauce_api_key_error']) if value.empty?
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
          "sauce_apps",
          "sauce_apps(
            platform: 'android',
            app_name: 'Android.MyCustomApp.apk',
            region: 'eu',
            sauce_username: 'sauce username',
            sauce_access_key: 'sauce api name'
          )"
        ]
      end

      def self.output
        [
          ['SAUCE_APP_ID', 'App id of uploaded app.']
        ]
      end

      def self.return_value
        "Returns the application id of the app uploaded"
      end
    end
  end
end
