# frozen_string_literal: true

namespace :datasets do
  desc 'Create dataset records from folder names, setting owner and creation time from metadata.yaml'
  task create_from_folders: :environment do
    DatasetCreator.new.create_dataset
  end

  task delete_datasets_from_db: :environment do
    dataset_path = Rails.root.join('public', 'downloads')
    folder_names = FolderParser.folder_names(dataset_path)

    Dataset.find_each do |dataset|
      unless folder_names.include?(dataset.name)
        dataset.destroy
        puts "Deleted #{dataset.name} from db"
      end
    end
  end

  private

  def create_images(images_path, dataset)
    Dir.children(images_path).each do |image_name|
      next if image_name.downcase.end_with?('.yaml', '.yml', '.txt')

      path_to_image = File.join(dataset.name, image_name)
      Image.find_or_create_by(name: image_name, dataset_id: dataset.id, path: path_to_image)
    end
  end
end
