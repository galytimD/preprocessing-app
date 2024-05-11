class DatasetSerializer < ActiveModel::Serializer
  attributes :id, :name, :status, :quality_status, :create_time, :image_count

  def image_count
    object.images.count
  end
  def create_time
    # Форматируем время создания в необходимый формат
    object.createTime.strftime("%-d %b. %Y %H:%M")
  end
end
