# frozen_string_literal: true

class Dataset < ApplicationRecord
  has_many :images, dependent: :delete_all
  enum status: {
    unprocessed: 0,
    data_engineered: 1,
    preprocessed: 2,
    ready: 3
  }
  enum quality_status: {
    not_evaluated: 0,
    excellent: 1,
    good: 2,
    fair: 3,
    poor: 4
  }
  def preprocessing_params
    {
      normalize: normalize,
      gamma: gamma,
      median_filter: median_filter,
      resize: resize,
      rotate: rotate,
      sharpen: sharpen,
      threshold: threshold
    }
  end
end
