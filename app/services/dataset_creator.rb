# frozen_string_literal: true

class DatasetCreator
  def create_dataset
    dataset_path = Rails.root.join('public', 'downloads')

    FolderParser.folder_names(dataset_path).each do |folder_name|
      metadata_path = File.join(dataset_path, folder_name, 'folder_metadata.yml')
      next unless File.exist?(metadata_path) # Пропускаем папки без метаданных

      metadata = YAML.load_file(metadata_path) || {}
      dataset = Dataset.find_or_create_by(name: folder_name) do |ds|
        ds.owner = metadata['Owners']
        ds.createTime = metadata['Created Time']
      end

      create_images(File.join(dataset_path, folder_name), dataset)
      puts "Dataset created with name: #{folder_name}, owner: #{metadata['Owners']}, created at: #{metadata['Created Time']}"
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
