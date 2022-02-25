require 'uri'
require 'net/http'
require 'json'
require_relative 'api'

module Fastlane
  module Saucectl
    # This class provides the ability to store, delete, and retrieve data from the Sauce Labs Storage API
    class Storage
      def initialize(config)
        @config = config
      end

      # Get App Storage Files
      # @return the set of files that have been uploaded to Sauce Storage by the requester.
      def retrieve_all_apps
        api = Fastlane::Saucectl::Api.new(@config)
        api.retrieve_all_apps
      end

      # Delete app by the Sauce Labs identifier of the stored file. You can look up file IDs using the Get App Storage Files endpoint.
      # https://docs.saucelabs.com/dev/api/storage/#get-app-storage-files
      # @return json response containing the file id and the number of files deleted.
      def delete_app_with_file_id
        api = Fastlane::Saucectl::Api.new(@config)
        api.delete_app("v1/storage/files/#{@config[:app_id]}")
      end

      # Deletes the specified group of files from Sauce Storage.
      # The Sauce Labs identifier of the group of files. You can look up file IDs using the Get App Storage Groups endpoint.
      # https://docs.saucelabs.com/dev/api/storage/#get-app-storage-groups
      # @return json response containing the group ID and the number of files deleted.
      def delete_all_apps_for_group_id
        path = "v1/storage/files/#{@config[:group_id]}"
        api = Fastlane::Saucectl::Api.new(@config)
        api.delete_app(path)
      end

      # Uploads an application file to Sauce Storage for the purpose of mobile application testing
      # @return a unique file ID assigned to the app.
      def upload_app
        Fastlane::Saucectl::Api.new(@config).upload
      end
    end
  end
end
