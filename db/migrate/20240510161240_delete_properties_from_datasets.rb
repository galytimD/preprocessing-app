class DeletePropertiesFromDatasets < ActiveRecord::Migration[7.1]
  def change
    remove_column :datasets, :normalize
    remove_column :datasets, :gamma
    remove_column :datasets, :median_filter
    remove_column :datasets, :resize
    remove_column :datasets, :rotate
    remove_column :datasets, :sharpen
    remove_column :datasets, :threshold
  end
end
