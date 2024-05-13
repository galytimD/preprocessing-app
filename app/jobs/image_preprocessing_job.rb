class ImagePreprocessingJob < ApplicationJob
  
    def perform(params)
      Images::Preprocessor.augmentation(params[:dataset_id], params)
    end
  end
  