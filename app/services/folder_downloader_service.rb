# frozen_string_literal: true

class FolderDownloaderService
  require_relative '../../app/services/google_drive/api'
  require_relative '../../app/services/google_drive/metadata_presence_checker'
  require_relative '../../app/services/google_drive/folder_downloader'
  require 'google/apis/drive_v3'

  def self.download_datasets
    drive_api = GoogleDrive::Api.new
    metadata_checker = GoogleDrive::MetadataPresenceChecker.new(drive_api)
    folder_downloader = GoogleDrive::FolderDownloader.new(drive_api)

    folder_id = Rails.application.credentials.dig(:google_drive, :dataset_folder_id)
    raise ArgumentError, 'Folder ID is not configured in credentials' unless folder_id

    puts "Fetching files from folder #{folder_id}..."
    folder_downloader.download_folder(folder_id)
  end
end
