require 'fileutils'
require 'mini_magick'

class ImagePreprocessor
  def initialize(dataset, options = {})
    puts options
    @dataset = dataset
    @images_path = Rails.root.join('public', 'downloads', dataset.name)
    @preprocessed_images_path = Rails.root.join('public', 'preprocessed', dataset.name)
    @options = options
    FileUtils.mkdir_p(@preprocessed_images_path) unless Dir.exist?(@preprocessed_images_path)
  end

  def process
    Dir.glob(File.join(@images_path, '**', '*.{jpg,jpeg,png,gif}')).each do |image_path|
      process_image(image_path)
    end
    update_dataset_images_path
  end
  private

  def process_image(image_path)
    puts "Processing image: #{image_path}"
    image = MiniMagick::Image.open(image_path)
    #image  = normalize_pixels(image) if @options[:normalize]
    #image  = adjust_gamma(image) if @options[:gamma]
    #image  = apply_median_filter(image) if @options[:median_filter]
    image  = resize_image(image) if @options[:resize]
    image  = rotate_image(image) if @options[:rotate]
    image  = sharpen_image(image) if @options[:sharpen]
    #image  = apply_threshold(image) if @options[:threshold]
    new_image_path = File.join(@preprocessed_images_path, File.basename(image_path))
    image.write(new_image_path)
    puts "Saving processed image to: #{new_image_path}"
  end

  def update_dataset_images_path
    @dataset.update(images_path: "preprocessed/#{@dataset.name}")
  end


  # Автоматическое выравнивание уровней
  def normalize_pixels(image)
    image.auto_level
  end

  # Гамма-коррекция для регулировки яркости
  def adjust_gamma(image)
    image.gamma(@options[:gamma])
  end

  # Применение медианного фильтра для уменьшения шума
  def apply_median_filter(image)
    image.median(@options[:median_filter])
  end

  
  # Изменение размера изображения
  def resize_image(image)
    image.resize(@options[:resize])
  end

  # Поворот изображения на заданный угол
  def rotate_image(image)
    image.rotate(@options[:rotate])
  end

  # Увеличение резкости изображения
  def sharpen_image(image)
    image.sharpen(@options[:sharpen])
  end

  # Бинаризация изображения по заданному порогу
  def apply_threshold(image)
    # Преобразование в градации серого для бинаризации
    image.colorspace 'Gray'
    image.threshold(@options[:threshold])
  end
end
