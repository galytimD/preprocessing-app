module GoogleDrive
  class FolderDownloader
    DOWNLOADS_DIR = Rails.root.join('public', 'downloads').freeze

    def initialize(drive_api)
      @drive_api = drive_api
    end

    def download_folder(folder_id, local_path = DOWNLOADS_DIR, parent_metadata = nil)
      query = "'#{folder_id}' in parents"
      fields = 'nextPageToken, files(id, name, mime_type, parents, createdTime, modifiedTime, owners(emailAddress))'
      response = @drive_api.list_files(query, fields)

      write_metadata_file(local_path, parent_metadata) if parent_metadata

      response.files.each do |file|
        local_folder_path = File.join(local_path, "dataset_#{file.created_time&.to_s}")
        if Dir.exist?(local_folder_path)
                  puts "Folder #{file.name} already downloaded. Skipping..."
                  next
        end
        if file.mime_type == 'application/vnd.google-apps.folder'
          # Проверка, содержит ли папка файлы или другие папки
          folder_contents_query = "'#{file.id}' in parents"
          folder_contents_response = @drive_api.list_files(folder_contents_query, fields)

          if folder_contents_response.files.empty?
            puts "Folder #{file.name} is empty. Skipping..."
            next
          end
          
          # Проверка, существует ли уже папка с таким именем
          FileUtils.mkdir_p(local_folder_path) unless Dir.exist?(local_folder_path)
          puts "Found folder: #{file.name}, downloading contents..."

          folder_metadata = parent_metadata.nil? ? extract_metadata(file) : nil
          download_folder(file.id, local_folder_path, folder_metadata)
        elsif parent_metadata
          download_file(file, local_path)
        end
      end
    end


    private

    def download_file(file, local_path)
      destination_path = File.join(local_path, file.name)
      puts "Downloading file: #{file.name} to #{destination_path}..."
      @drive_api.download_file(file.id, destination_path)
    end

    def write_metadata_file(local_path, metadata)
      metadata_file_path = File.join(local_path, 'folder_metadata.yml')
      File.open(metadata_file_path, 'w') { |file| file.write(metadata.to_yaml) }
      puts "Metadata saved to #{metadata_file_path}"
    end

    def extract_metadata(file)
      {
        'Name' => "dataset_#{file.created_time&.to_s}",
        'Created Time' => file.created_time&.to_s,
        'Modified Time' => file.modified_time&.to_s,
        'Owners' => file.owners&.map(&:email_address)&.join(', ') || 'Unknown Owner'
      }
    end
  end
end
