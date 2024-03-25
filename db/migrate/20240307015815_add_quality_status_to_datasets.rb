# frozen_string_literal: true

class AddQualityStatusToDatasets < ActiveRecord::Migration[7.1]
  def change
    add_column :datasets, :quality_status, :integer, default: 0
  end
end
