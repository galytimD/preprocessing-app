# frozen_string_literal: true

namespace :google_drive do
  desc 'Download all files from the specified Google Drive folder stored in credentials'
  task download_files: :environment do
    FolderDownloaderService.download_datasets
  end
  task upload_folder_contents: :environment do
    FolderUploaderService.upload_folder_contents
  end

end
