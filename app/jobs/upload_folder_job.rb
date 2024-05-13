class UploadFolderJob < ApplicationJob
  queue_as :default

  def perform(upload_params)
    FolderUploaderService.new(upload_params[:project_name]).upload_folder
  end
end
