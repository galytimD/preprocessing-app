# frozen_string_literal: true

module GoogleDrive
  class MetadataPresenceChecker
    METADATA_FILE_NAME = 'dataset_metadata.yml'

    def initialize(drive_api)
      @drive_api = drive_api
    end

    def metadata_count_matches?(folder_id)
      metadata_file = find_metadata_file(folder_id)
      return false unless metadata_file

      metadata_count = read_metadata_count(metadata_file.id)
      return false unless metadata_count

      images_count = count_images_in_folder(folder_id)
      images_count == metadata_count
    end

    private

    def find_metadata_file(folder_id)
      query = "'#{folder_id}' in parents and name = '#{METADATA_FILE_NAME}'"
      response = @drive_api.list_files(query, 'files(id, name)', page_size: 1)
      response.files.first
    end

    def read_metadata_count(file_id)
      content = @drive_api.get_file_content(file_id)
      metadata = YAML.safe_load(content)
      metadata['count']
    rescue StandardError
      nil
    end

    def count_images_in_folder(folder_id)
      query = "'#{folder_id}' in parents and mimeType contains 'image/'"
      response = @drive_api.list_files(query, 'files(id, name)', page_size: 1000)
      response.files.count
    end
  end
end
