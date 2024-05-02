# frozen_string_literal: true

class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :edit, :update, :destroy, :preprocessing, :update_preprocessing]
  def index
    @datasets = Dataset.all
    datasets_with_image_count = []
  
    @datasets.each do |dataset|
      dataset_info = dataset.as_json(only: [:id, :name, :status, :quality_status, :createTime])
      dataset_info[:imageCount] = dataset.images.count
      datasets_with_image_count << dataset_info
    end
  
    render json: datasets_with_image_count
  end

  def show
    render :json => @dataset.images.to_json( :except => [:updated_at]) 
  end

  def download_datasets
    flash[:notice] = 'Скачивание датасетов инициировано.'
    FolderDownloaderService.download_datasets
    DatasetCreator.new.create_dataset
    redirect_to datasets_path
  end

  def edit; end

  def update
    respond_to do |format|
      if @dataset.update(dataset_params)
        format.html { redirect_to dataset_url(@dataset), notice: 'Dataset was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }

      end
    end
  end

  def destroy
    @dataset.destroy!

    respond_to do |format|
      format.html { redirect_to datasets_url, notice: 'Dataset was successfully destroyed.' }
    end
  end

  def update_preprocessing
    if @dataset.update(preprocessing_params)
      # Вызов сервиса для обработки изображений
      process_images
      render :edit, notice: 'Параметры предобработки успешно обновлены, изображения обработаны.'
    else
      render :preprocessing
    end
  end
  def preproccessing_one
  
  end



  private

  def preprocessing_params
    params.require(:dataset).permit(:normalize, :gamma, :median_filter, :color_space, :resize, :rotate, :sharpen, :threshold)
  end

  def process_images
    options = preprocessing_params.to_h.symbolize_keys
    preprocessor = ImagePreprocessor.new(@dataset, options)
    preprocessor.process
  end


  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  def dataset_params
    params.require(:dataset).permit(:name, :data, :status)
  end
  def preprocessing_params
    params.require(:dataset).permit(:normalize, :gamma, :median_filter, :resize, :rotate, :sharpen, :threshold)
  end
end
