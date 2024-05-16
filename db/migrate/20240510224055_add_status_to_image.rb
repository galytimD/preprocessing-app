class AddStatusToImage < ActiveRecord::Migration[7.1]
  def change
    add_column :images, :uploaded, :boolean , :default => false
    add_column :images, :preprocessed, :boolean , :default => false
    change_column :images, :dataset_id, :integer, :null =>  true
  end
end
