class FolderUploaderService
    require_relative '../../app/services/google_drive/api'
    require 'google/apis/drive_v3'
  
    def self.upload_folder
      drive_service = GoogleDrive::Api.new.drive_service
      folder_id = №Rails.application.credentials.dig(:google_drive, :folder_id)
      raise ArgumentError, 'Folder ID is not configured in credentials' unless folder_id
  
      folder_path = Rails.root.join('public', 'preprocessed')
      upload_folder_recursive(drive_service, folder_id, folder_path)
      puts "All folders uploaded successfully."
    end
  
    private
  
    def self.upload_folder_recursive(drive_service, parent_folder_id, folder_path)
      folder_name = File.basename(folder_path)
      sub_folder_id = create_folder(drive_service, parent_folder_id, folder_name)
      puts "Folder '#{folder_name}' uploaded successfully."
  
      Dir.foreach(folder_path) do |file_name|
        next if file_name == '.' || file_name == '..'
  
        file_path = File.join(folder_path, file_name)
        if File.directory?(file_path)
          upload_folder_recursive(drive_service, sub_folder_id, file_path)
        end
      end
    end
  
    def self.create_folder(drive_service, parent_folder_id, folder_name)
      folder_metadata = {
        name: folder_name,
        parents: [parent_folder_id],
        mime_type: 'application/vnd.google-apps.folder'
      }
      begin
        folder = drive_service.create_file(folder_metadata, fields: 'id')
        folder.id
      rescue StandardError => e
        puts "Error creating folder '#{folder_name}': #{e.message}"
        nil
      end
    end
  end
  