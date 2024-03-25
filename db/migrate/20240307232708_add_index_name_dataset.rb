# frozen_string_literal: true

class AddIndexNameDataset < ActiveRecord::Migration[7.1]
  def change
    add_index :datasets, :name, unique: true
  end
end
