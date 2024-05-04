# frozen_string_literal: true

namespace :ds do
  desc 'Create dataset records from folder names, setting owner and creation time from metadata.yaml'
  task create: :environment do
    DatasetCreator.new.create_dataset
  end

  task delete: :environment do
    dataset_path = Rails.root.join('public', 'downloads')
    folder_names = FolderParser.folder_names(dataset_path)

    Dataset.find_each do |dataset|
      unless folder_names.include?(dataset.name)
        dataset.destroy
        puts "Deleted #{dataset.name} from db"
      end
    end
  end
    desc "Delete datasets with zero images"
    task delete_without_images: :environment do
      Dataset.includes(:images).where(images: { id: nil }).destroy_all
      puts "Datasets with zero images have been deleted."
    end
  

  private

  def create_images(images_path, dataset)
    Dir.children(images_path).each do |image_name|
      next if image_name.downcase.end_with?('.yaml', '.yml', '.txt')

      path_to_image = File.join(images_path, dataset.name, image_name)
      full_image_path = File.join(images_path, image_name) # Полный путь к изображению для извлечения метаданных

      # Использование сервиса для извлечения метаданных
      metadata = Images::MetadataExtractor.extract(full_image_path)

      # Находим или создаем новую запись в базе данных с этими метаданными
      Image.find_or_create_by(name: image_name, dataset_id: dataset.id, path: path_to_image) do |image|
        image.coordinates = metadata[:coordinates]
        image.resolution = metadata[:resolution]
        image.orientation = metadata[:orientation]
      end
    end
  end
end
