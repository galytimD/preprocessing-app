class UploadFolderJob < ApplicationJob
  queue_as :default

  def perform(upload_params)
    FolderUploaderService.new(upload_params).upload_folder
  end
end
