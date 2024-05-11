class AddStatusToImage < ActiveRecord::Migration[7.1]
  def change
    add_column :images, :uploaded, :boolean , :default => false
  
  end
end
