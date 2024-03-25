# frozen_string_literal: true

class AddIndexesToImage < ActiveRecord::Migration[7.1]
  def change
    add_index :images, %i[name dataset_id], unique: true
  end
end
