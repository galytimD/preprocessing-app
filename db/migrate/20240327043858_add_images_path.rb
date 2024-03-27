class AddImagesPath < ActiveRecord::Migration[7.1]
  def change
    add_column :datasets, :images_path, :string, :null => false, :default =>  ""
  end
end
