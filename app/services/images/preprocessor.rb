require 'fileutils'
require 'mini_magick'
require 'parallel'
require 'open3'

module Images
  class Preprocessor
    OUTPUT_DIRECTORY = Rails.root.join('public', 'preprocessed').freeze

    def self.augmentation(dataset_id, params)
      dataset = Dataset.find(dataset_id)
      dataset.status = "ready"
      dataset.save
      imgs = dataset.images
      width = params[:width].to_i
      height = params[:height].to_i
      rotate = params[:rotate] == 'true' || params[:rotate] == true
      mirror = params[:mirror] == 'true' || params[:mirror] == true
      zoom = params[:zoom] == 'true' || params[:zoom] == true

      Parallel.each(imgs, in_threads: 8) do |img|
        input_path = Rails.root.join('public', img.path).freeze
        img_name = img.name.split(".")[0]
        if rotate
          output_path_rotated = "#{OUTPUT_DIRECTORY}/#{img_name}_rotated_#{rotation_angle}.jpg"
          process_image_with_rotation(input_path, output_path_rotated, width, height, rotation_angle)
        end

        if zoom
          output_path_zoomed = "#{OUTPUT_DIRECTORY}/#{img_name}_zoomed.jpg"
          process_image_with_zoom(input_path, output_path_zoomed, width, height, 1.5)
        end

        if mirror
          output_path_mirrored = "#{OUTPUT_DIRECTORY}/#{img_name}_mirrored.jpg"
          process_image_with_mirror(input_path, output_path_mirrored, width, height, direction)
        end
      end

      # Вызов скрипта для изменения прав доступа после завершения обработки
      change_permissions
    end

    def self.process_image_with_rotation(input_path, output_path, width, height, rotation_angle)
      process_image(input_path, output_path, width, height) do |image|
        rotate_image(image, rotation_angle)
      end
    end

    def self.process_image_with_zoom(input_path, output_path, width, height, zoom_factor)
      process_image(input_path, output_path, width, height) do |image|
        zoom_image(image, zoom_factor, width, height)
      end
    end

    def self.process_image_with_mirror(input_path, output_path, width, height, direction)
      process_image(input_path, output_path, width, height) do |image|
        mirror_image(image, direction)
      end
    end

    def self.process_image(input_path, output_path, width, height)
      begin
        image = MiniMagick::Image.open(input_path)

        resize_image(image, width, height)

        image.combine_options do |c|
          c.gravity 'center'
          c.crop "#{width-1}x#{height-1}+0+0"
        end

        yield(image) if block_given?

        image.format "jpg"
        
        image.write output_path
        name  = output_path.split("/")[-1]
        path = output_path.split("/")[-2..-1].join("/")
        Image.create(name: name, path: path, resolution: "#{width}x#{height}", preprocessed: true)
        puts "Изображение успешно обработано и сохранено как '#{output_path}'."
      rescue => e
        puts "Произошла ошибка: #{e.message}"
      end
    end

    private

    def self.rotation_angle
      [45, 90, 135, 180, 225, 270, 315].sample
    end

    def self.direction
      ['horizontal', 'vertical'].sample
    end

    def self.resize_image(image, width, height)
      image.combine_options do |c|
        c.resize "#{width}x#{height}^"
        c.gravity 'center'
        c.background 'black'
        c.extent "#{width}x#{height}"
      end
    end

    def self.rotate_image(image, angle)
      image.combine_options do |c|
        c.background 'black'
        c.rotate angle
      end
    end

    def self.zoom_image(image, zoom_factor, width, height)
      if zoom_factor && zoom_factor > 1
        new_width = (image.width * zoom_factor).round
        new_height = (image.height * zoom_factor).round
        image.resize "#{new_width}x#{new_height}"
        image.combine_options do |c|
          c.gravity 'center'
          c.crop "#{width}x#{height}+0+0"
        end
      end
    end

    def self.mirror_image(image, direction)
      case direction
      when 'horizontal'
        image.flop
      when 'vertical'
        image.flip
      else
        raise ArgumentError, "Direction must be 'horizontal' or 'vertical'"
      end
    end

    def self.change_permissions
      output_directory = OUTPUT_DIRECTORY.to_s
      command = "sudo chmod -R 777 #{output_directory}"
      stdout, stderr, status = Open3.capture3(command)
      if status.success?
        puts "Права доступа успешно изменены для директории #{output_directory}"
      else
        puts "Произошла ошибка при изменении прав доступа: #{stderr}"
      end
    end
  end
end
