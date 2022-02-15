require 'fastlane/action'
require 'json'
require 'yaml'
require_relative '../helper/api'
require_relative '../helper/storage'

module Fastlane
  module Actions
    class DeleteFromStorageAction < Action
      @messages = YAML.load_file("#{__dir__}/../strings/messages.yml")

      def self.run(params)
        if params[:group_id].nil?
          Fastlane::Saucectl::Storage.new(config(params)).delete_app_with_file_id
        else
          Fastlane::Saucectl::Storage.new(config(params)).delete_all_apps_for_group_id
        end
      end

      def self.config(params)
        {
          region: params[:region],
          platform: params[:platform],
          app_name: params[:app_name],
          sauce_username: params[:sauce_username],
          sauce_access_key: params[:sauce_access_key],
          app_id: params[:app_id],
          group_id: params[:group_id]
        }
      end

      def self.description
        "Delete test artifacts from sauce labs storage"
      end

      def self.details
        "Delete test artifacts from sauce labs storage by storage id or group id"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :region,
                                       description: "Data Center region (us or eu), set using: region: 'eu'",
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['region_error'].gsub!('$region', value)) unless @messages['supported_regions'].include?(value)
                                       end),
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
          FastlaneCore::ConfigItem.new(key: :app_id,
                                       description: "The application id from sauce labs storage",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :group_id,
                                       description: "The group id for sauce labs storage",
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
          "delete_from_storage",
          "delete_from_storage(
            region: 'eu',
            app_name: 'Android.MyCustomApp.apk',
            sauce_username: 'sauce username',
            sauce_access_key: 'sauce api name',
            app_id: '1234-1234-1234-1234'
          )",
          "delete_from_storage",
          "delete_from_storage(
            region: 'eu',
            app_name: 'Android.MyCustomApp.apk',
            sauce_username: 'sauce username',
            sauce_access_key: 'sauce api name',
            group_id: '123456789'
          )"
        ]
      end
    end
  end
end
