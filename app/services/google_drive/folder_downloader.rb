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
        local_folder_path = generate_unique_folder_name(File.join(local_path, "dataset_#{file.name.gsub(/\s+/, '_').gsub(/[^\w-]/, '')}"))

        if file.mime_type == 'application/vnd.google-apps.folder'
          folder_contents_query = "'#{file.id}' in parents"
          folder_contents_response = @drive_api.list_files(folder_contents_query, fields)

          if folder_contents_response.files.empty?
            puts "Folder #{file.name} is empty. Skipping..."
            next
          end
          
          FileUtils.mkdir_p(local_folder_path)
          puts "Found folder: #{file.name}, downloading contents..."

          folder_metadata = parent_metadata.nil? ? extract_metadata(file) : nil
          download_folder(file.id, local_folder_path, folder_metadata)
        elsif parent_metadata
          download_file(file, local_folder_path)
        end
      end
    end

    private

    def download_file(file, local_path)
      # Создание директории, если она не существует
      directory_path = File.dirname(local_path)
      FileUtils.mkdir_p(directory_path) unless Dir.exist?(directory_path)
    
      # Формирование корректного пути файла
      destination_path = File.join(directory_path, "#{file.name}.jpg")  # Убедитесь, что имя файла формируется корректно
    
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
        'Name' => file.name,
        'Created Time' => file.created_time&.to_s,
        'Modified Time' => file.modified_time&.to_s,
        'Owners' => file.owners&.map(&:email_address)&.join(', ') || 'Unknown Owner'
      }
    end

    def generate_unique_folder_name(base_folder_path)
      counter = 1
      unique_folder_path = base_folder_path
      while Dir.exist?(unique_folder_path)
        unique_folder_path = "#{base_folder_path}-#{counter}"
        counter += 1
      end
      unique_folder_path
    end
  end
end
