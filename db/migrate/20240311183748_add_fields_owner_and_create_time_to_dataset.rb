# frozen_string_literal: true

class AddFieldsOwnerAndCreateTimeToDataset < ActiveRecord::Migration[7.1]
  def change
    add_column :datasets, :owner, :string
    add_column :datasets, :createTime, :datetime
  end
end
