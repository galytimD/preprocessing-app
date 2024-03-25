# frozen_string_literal: true

class ImagesController < ApplicationController
  before_action :set_dataset

  def batch_destroy
    ImageRemovalService.new(Image.where(id: params[:image_ids])).call if params[:image_ids].present?
    redirect_to edit_dataset_path(@dataset), notice: 'Выбранные изображения были успешно удалены.'
  end

  private

  def set_dataset
    @dataset = Dataset.find(params[:dataset_id])
  end
end
