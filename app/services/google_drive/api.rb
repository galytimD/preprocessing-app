# frozen_string_literal: true

module GoogleDrive
  class Api
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
      # Используем StringIO как буфер в памяти для временного хранения содержимого файла
      io = StringIO.new
      @drive_service.get_file(file_id, download_dest: io)
      # Возвращаем содержимое файла в виде строки
      io.string
    end
  end
end
