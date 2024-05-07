# frozen_string_literal: true

class ImagesController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :set_dataset, except: :coordinates
  before_action :set_image, only: [:destroy]

  def destroy
    @image.destroy
    @dataset.destroy if @dataset.images.empty?
    render json: {message: 'Delete success'}

  end

  def batch_destroy
    Images::RemovalService.new(Image.where(id: params[:image_ids])).call if params[:image_ids].present?
    redirect_to edit_dataset_path(@dataset), notice: 'Выбранные изображения были успешно удалены.'
  end
  def coordinates
    images = Image.where.not(coordinates: [nil, ""]).distinct
  
    result = images.map do |image|
      { id: image.id, coordinates: image.coordinates.split(",").map(&:to_f) }
    end
    render json: result
  end
  



  private

  def set_dataset
    @dataset = Dataset.find(params[:dataset_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to datasets_path, alert: 'Датасет не найден.'
  end

  def set_image
    @image = @dataset.images.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to edit_dataset_path(@dataset), alert: 'Изображение не найдено.'
  end
end
