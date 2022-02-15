require 'fastlane/action'
require 'json'
require 'yaml'
require_relative '../helper/api'

module Fastlane
  module Actions
    module SharedValues
      SAUCE_APP_ID = :SAUCE_APP_ID
    end

    class UploadToSaucelabsAction < Action
      @messages = YAML.load_file("#{__dir__}/../strings/messages.yml")

      def self.run(params)
        response = Fastlane::Saucectl::Api.new(config(params)).upload
        body = JSON.parse(response.body)
        ENV['SAUCE_APP_ID'] = body['items'][0]['id']
      end

      def self.config(params)
        {
          platform: params[:platform],
          app_path: params[:app_path],
          app_name: params[:app_name],
          app_description: params[:app_description],
          region: params[:region],
          sauce_username: params[:sauce_username],
          sauce_access_key: params[:sauce_access_key]
        }
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
          FastlaneCore::ConfigItem.new(key: :app_path,
                                       description: "Path to the application under test",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['app_path_error']) unless value && !value.empty?
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
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_description,
                                       description: "A description to distinguish your app",
                                       optional: true,
                                       is_string: true)
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
          "upload_to_saucelabs",
          "upload_to_saucelabs(
            platform: 'android',
            app_path: 'app/build/outputs/apk/debug/app-debug.apk',
            app_name: 'Android.MyCustomApp.apk',
            app_description: 'description of my app'
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
