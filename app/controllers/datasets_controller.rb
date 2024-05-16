class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :update, :destroy]
  
  def index
    render json: Dataset.all
  end
  
  def show
    render json: @dataset.images.where(preprocessed: false)
  end

  def preprocessed
    render json: Image.where(preprocessed: true).where(uploaded: false)
  end

  def download
    FolderDownloaderService.download_datasets
    DatasetCreator.new.create_dataset
    render json: { message: "Датасеты загружены" }
  end

  def upload
    UploadFolderJob.perform_later(upload_params)
    render json: { message: upload_params }
  end

  def update
    if @dataset.update(dataset_params)
      render json: { message: 'Dataset was successfully updated.' }
    else
      render json: { errors: @dataset.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @dataset.destroy
    render json: { message: 'Dataset was successfully destroyed.' }
  end

  def preprocessing

    ImagePreprocessingJob.perform_later(preprocessing_params)
    render json: {message: preprocessing_params }

  end

  private

  def dataset_params
    params.require(:dataset).permit(:name, :data, :status)
  end

  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  def preprocessing_params
    params.permit(:width,:height,:rotate,:zoom,:mirror,:dataset_id)
  end

  def upload_params
    params.permit(:project_name)
  end
end