class DatasetsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_dataset, only: [:show, :update, :destroy, :preprocessing_one, :preprocessing_all]

  def index
    render json: Dataset.all
  end
  
  def show
    render json: @dataset.images
  end

  def download
    FolderDownloaderService.download_datasets
    DatasetCreator.new.create_dataset
    render json: { message: "Датасеты загружены" }
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

  def preprocessing_all
    Images::Preprocessor.new(@dataset, options).all
    render json: { message: "Все фото обработаны" }
  end

  def preprocessing_one
    Images::Preprocessor.new(@dataset, options).one
    render json: { message: "Одно фото обработано" }
  end

  private

  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  def dataset_params
    params.require(:dataset).permit(:name, :data, :status)
  end

  def preprocessing_params
    params.require(:dataset).permit(:normalize, :resize)
  end

  def options
    preprocessing_params.to_h.symbolize_keys
  end
end
