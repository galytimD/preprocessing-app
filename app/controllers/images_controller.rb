# frozen_string_literal: true

class ImagesController < ApplicationController
  

  before_action :set_dataset, only: [:destroy, :batch_destroy]
  before_action :set_image, only: [:destroy]

  def destroy
    @image.destroy
    @dataset.status = "data_engineered"
    @dataset.save
    @dataset.destroy if @dataset.images.empty?
    render json: { message: 'Delete success' }
  end

  def count_preproccessed
    render json: { count: Image.count }
  end

  def batch_destroy
    if params[:image_ids].present?
      Images::RemovalService.new(Image.where(id: params[:image_ids])).call
      render json: { message: 'Images successfully deleted.' }
    else
      render json: { message: 'No images to delete.' }, status: :unprocessable_entity
    end
  end

  def coordinates
    # images = Image.where.not(coordinates: [nil, ""]).distinct
    # result = images.map { |image| { id: image.id, coordinates: image.coordinates.split(",").map(&:to_f) } }
    # render json: result
    #result = Dataset.generate_vineyard_data
    result = Dataset.fake_data
    #Dataset.save_vineyard_data_to_file("fake_data.json",result)
    render json: result
    
    
  end
  
  private

  def set_dataset
    @dataset = Dataset.find_by(id: params[:dataset_id])
    render json: { alert: 'Dataset not found.' }, status: :not_found unless @dataset
  end

  def set_image
    @image = @dataset.images.find_by(id: params[:id])
    render json: { alert: 'Image not found.' }, status: :not_found unless @image
  end
end
