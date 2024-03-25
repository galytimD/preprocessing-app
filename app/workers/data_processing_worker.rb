# frozen_string_literal: true

class DataProcessingWorker
  include Sidekiq::Worker

  def perform
    FolderDownloaderService.download_datasets
    DatasetCreator.new.create_dataset
  end
end
