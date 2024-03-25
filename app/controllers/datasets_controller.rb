# frozen_string_literal: true

class DatasetsController < ApplicationController
  before_action :set_dataset, only: %i[show edit update destroy]
  def index
    @datasets = Dataset.all
  end

  def show; end

  def download_datasets
    flash[:notice] = 'Скачивание датасетов инициировано.'
    FolderDownloaderService.download_datasets
    DatasetCreator.new.create_dataset
    redirect_to datasets_path
  end

  def preprocessing; end

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

  private

  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  def dataset_params
    params.require(:dataset).permit(:name, :data, :status)
  end
end
