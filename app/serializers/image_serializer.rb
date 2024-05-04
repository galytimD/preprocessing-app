class ImageSerializer < ActiveModel::Serializer
  attributes :id, :name, :coordinates, :resolution, :orientation
  
end
