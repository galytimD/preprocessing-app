# frozen_string_literal: true

class DeleteFieldDataFromDataset < ActiveRecord::Migration[7.1]
  def change
    remove_column :datasets, :data
  end
end
