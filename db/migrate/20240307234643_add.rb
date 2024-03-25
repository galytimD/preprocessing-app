# frozen_string_literal: true

class Add < ActiveRecord::Migration[7.1]
  def change
    add_column :images, :path, :string
  end
end
