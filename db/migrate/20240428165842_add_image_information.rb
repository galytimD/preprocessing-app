class AddImageInformation < ActiveRecord::Migration[7.1]
  def change
    add_column :images, :coordinates, :string
    add_column :images, :resolution, :string
    add_column :images, :orientation, :string
  end
end
