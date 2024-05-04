require 'fileutils'
require 'mini_magick'

module Images
  class Preprocessor
    def initialize(dataset, options = {})
      @dataset = dataset
      @images_path = Rails.root.join('public', 'downloads', dataset.name)
      @preprocessed_images_path = Rails.root.join('public', 'preprocessed', dataset.name)
      @options = options
      FileUtils.mkdir_p(@preprocessed_images_path) unless Dir.exist?(@preprocessed_images_path)
    end

    def all
      Dir.glob(File.join(@images_path, '**', '*.{jpg,jpeg,png,gif}')).each do |image_path|
        process_image(image_path)
      end
      update_dataset_images_path
    end
    def one
     
    end

    private

    def process_image(image_path)
      image = MiniMagick::Image.open(image_path)
      image = normalize_pixels(image)
      image = resize_image(image)
      save_processed_image(image, image_path)
    end

    def normalize_pixels(image)
      image.auto_level
    end

    def resize_image(image)
      image.resize(@options[:resize])
    end

    def save_processed_image(image, original_path)
      new_image_path = File.join(@preprocessed_images_path, File.basename(original_path))
      image.write(new_image_path)
    end

    def update_dataset_images_path
      @dataset.update(images_path: "preprocessed/#{@dataset.name}")
    end
  end
end
