class DatasetSerializer < ActiveModel::Serializer
  attributes :id, :name, :status, :quality_status, :createTime, :image_count

  def image_count
    object.images.count
  end
  
end
