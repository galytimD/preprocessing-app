# frozen_string_literal: true

class CreateDatasets < ActiveRecord::Migration[7.1]
  def change
    create_table :datasets do |t|
      t.string :name
      t.string :data
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
