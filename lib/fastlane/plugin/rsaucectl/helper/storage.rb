require 'uri'
require 'net/http'
require 'json'
require_relative 'api'

module Fastlane
  module Saucectl
    # This class provides the ability to store, delete, and retrieve data from the Sauce Labs Storage API
    class Storage
      UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

      def initialize(config)
        @config = config
      end

      # Get App Storage Files
      # @return the set of files that have been uploaded to Sauce Storage by the requester.
      def retrieve_all_apps
        api = Fastlane::Saucectl::Api.new(@config)
        api.retrieve_all_apps
      end

      # Delete an App Storage File
      # @param file_id [String] The file id of the app to delete (optional - defaults to nil)
      # @param file_index [String] The index of the file to delete (optional - defaults to 0)
      # @return json response containing the file id and the number of files deleted.
      def delete_app_with(file_id = nil, file_index = 0)
        id = if file_id.nil?
               response = JSON.parse(retrieve_all_apps.body)
               response['items'][file_index]['id']
             else
               file_id
             end

        api = Fastlane::Saucectl::Api.new(@config)
        api.delete_app("v1/storage/files/#{id}")
      end

      # Deletes the specified group of files from Sauce Storage.
      # @param group_id String : The Sauce Labs identifier of the group of files.
      # You can look up file IDs using the Get App Storage Groups endpoint.
      # @return json response containing the group ID and the number of files deleted.
      def delete_all_apps_for(group_id)
        path = "v1/storage/files/#{group_id}"
        api = Fastlane::Saucectl::Api.new(@config)
        api.delete_app(path)
      end

      # Uploads an application file to Sauce Storage for the purpose of mobile application testing
      # @param description [String] A description of the file
      # @return a unique file ID assigned to the app.
      def upload_app(description = nil)
        Fastlane::Saucectl::Api.new(@config).upload
      end
    end
  end
end
