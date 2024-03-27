class AddPreprocessingParamsToDatasets < ActiveRecord::Migration[7.1]
  def change
    add_column :datasets, :normalize, :boolean, default: false
    add_column :datasets, :gamma, :string
    add_column :datasets, :median_filter, :string
    add_column :datasets, :resize, :string
    add_column :datasets, :rotate, :string
    add_column :datasets, :sharpen, :string
    add_column :datasets, :threshold, :string
  end
end
