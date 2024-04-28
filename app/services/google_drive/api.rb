module GoogleDrive
  class Api
    attr_reader :drive_service

    def initialize
      @drive_service = Google::Apis::DriveV3::DriveService.new
      @drive_service.client_options.application_name = 'Your Application Name'
      @drive_service.authorization = Authorizer.authorize
    end

    def list_files(query, fields, page_size: 1000)
      @drive_service.list_files(q: query, fields: fields, page_size: page_size)
    end

    def download_file(file_id, destination_path)
      File.open(destination_path, 'wb') do |file|
        @drive_service.get_file(file_id, download_dest: file)
      end
    end

    def get_file_content(file_id)
      # Use StringIO as a buffer in memory to temporarily store file content
      io = StringIO.new
      @drive_service.get_file(file_id, download_dest: io)
      # Return file content as a string
      io.string
    end

    def create_folder(parent_folder_id, folder_name)
      folder_metadata = Google::Apis::DriveV3::File.new(name: folder_name, parents: [parent_folder_id], mime_type: 'application/vnd.google-apps.folder')
      @drive_service.create_file(folder_metadata, fields: 'id')
    end

    def upload_file(parent_folder_id, file_path, file_name)
      file_metadata = Google::Apis::DriveV3::File.new(name: file_name, parents: [parent_folder_id])
      file = File.open(file_path, 'rb')
      @drive_service.create_file(file_metadata, upload_source: file)
    end
  end
end

