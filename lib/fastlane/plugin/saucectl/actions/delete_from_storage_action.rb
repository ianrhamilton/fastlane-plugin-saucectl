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
          Fastlane::Saucectl::Storage.new(params).delete_app_with_file_id
        else
          Fastlane::Saucectl::Storage.new(params).delete_all_apps_for_group_id
        end
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
                                         UI.user_error!(@messages['region_error'].gsub!('$region', value)) if value.empty? || !@messages['supported_regions'].include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :sauce_username,
                                       env_name: "SAUCE_USERNAME",
                                       description: "Your sauce labs username in order to authenticate delete file from app storage",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_USERNAME],
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!(@messages['sauce_username_error']) if value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :sauce_access_key,
                                       env_name: "SAUCE_ACCESS_KEY",
                                       description: "Your sauce labs access key in order to authenticate delete file from app storage",
                                       default_value: Actions.lane_context[SharedValues::SAUCE_ACCESS_KEY],
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
          "delete_from_storage(
            region: 'eu',
            sauce_username: 'sauce username',
            sauce_access_key: 'sauce api name',
            app_id: '1234-1234-1234-1234'
          )",
          "delete_from_storage(
            region: 'eu',
            sauce_username: 'sauce username',
            sauce_access_key: 'sauce api name',
            group_id: '123456789'
          )"
        ]
      end
    end
  end
end
