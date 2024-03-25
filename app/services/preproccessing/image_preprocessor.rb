require 'mini_magick'

class ImagePreprocessor
  # Инициализация сервиса с путем к изображениям и опциями обработки
  def initialize(images_path, options = {})
    @images_path = images_path
    @options = options
  end

  # Основной метод для запуска процесса предобработки всех изображений в папке
  def process
    Dir.glob(File.join(@images_path, '**', '*.{jpg,jpeg,png,gif}')).each do |image_path|
      process_image(image_path)
    end
  end

  private

  def process_image(image_path)
    image = MiniMagick::Image.open(image_path)

    # Нормализация (автоматическое выравнивание уровней)
    normalize_pixels(image) if @options[:normalize]
    
    # Гамма-коррекция для регулировки яркости
    adjust_gamma(image) if @options[:gamma]
    
    # Применение медианного фильтра для уменьшения шума
    apply_median_filter(image) if @options[:median_filter]
    
    # Преобразование цветового пространства (например, в Grayscale)
    convert_color_space(image) if @options[:color_space]
    
    # Изменение размера изображения
    resize_image(image) if @options[:resize]
    
    # Поворот изображения на заданный угол
    rotate_image(image) if @options[:rotate]
    
    # Увеличение резкости изображения
    sharpen_image(image) if @options[:sharpen]
    
    # Изменение перспективы изображения
    perspective_transform(image) if @options[:perspective]
    
    # Бинаризация изображения по заданному порогу
    apply_threshold(image) if @options[:threshold]

    image.write(image_path)
  end

  def normalize_pixels(image)
    image.auto_level
  end

  def adjust_gamma(image)
    image.gamma(@options[:gamma])
  end

  def apply_median_filter(image)
    image.median(@options[:median_filter])
  end

  def convert_color_space(image)
    image.colorspace(@options[:color_space])
  end

  def resize_image(image)
    image.resize(@options[:resize])
  end

  def rotate_image(image)
    image.rotate(@options[:rotate])
  end

  def sharpen_image(image)
    image.sharpen(@options[:sharpen])
  end

  def perspective_transform(image)
    # Этот метод требует кастомной реализации в зависимости от требуемой трансформации
  end

  def apply_threshold(image)
    image.colorspace 'Gray'
    image.threshold(@options[:threshold])
  end
end
