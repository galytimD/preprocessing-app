class ImageSerializer < ActiveModel::Serializer
  attributes :id, :name, :coordinates,:path, :resolution, :orientation
  
end
