# frozen_string_literal: true

class Dataset < ApplicationRecord
  has_many :images, dependent: :delete_all
  def self.fake_data
    file_path = Rails.root.join('fake_data.json')
    if File.exist?(file_path)
      JSON.parse(File.read(file_path))
    else
      puts "File not found: #{file_path}"
      []
    end
  end
  def self.generate_vineyard_data
    vineyards = []
    # Координаты углов поля
    top_left = [44.749019, 33.574857]
    bottom_left = [44.746671, 33.575362]
    bottom_right = [44.746403, 33.572046]
    top_right = [44.748735, 33.571767]

    # Определяем шаги для вычисления координат
    col_step_lat = (top_right[0] - top_left[0]) / 9.0
    col_step_lon = (top_right[1] - top_left[1]) / 9.0

    row_step_lat = (bottom_left[0] - top_left[0]) / 38.0
    row_step_lon = (bottom_left[1] - top_left[1]) / 38.0

    10.times do |col|
      grapes = []
      # Генерируем уникальные индексы для больных кустов
      sick_grape_indices = (0...39).to_a.sample(rand(1..6))

      39.times do |row|
        lat = top_left[0] + col * col_step_lat + row * row_step_lat
        lon = top_left[1] + col * col_step_lon + row * row_step_lon
        grapes << {
          id: col * 40 + row + 1,
          coordinates: [lat, lon],
          health: sick_grape_indices.include?(row) ? false : true
        }
      end
      vineyards << { id: col + 1, grapes: grapes }
    end

    vineyards
  end

  def self.save_vineyard_data_to_file(filename, data)
    
    File.open(filename, 'w') do |file|
      file.write(JSON.pretty_generate(data))
    end
    puts "Data saved to #{filename}"
  end

  enum status: {
    unprocessed: 0,
    data_engineered: 1,
    ready: 2
  }
  enum quality_status: {
    not_evaluated: 0,
    excellent: 1,
    good: 2,
    fair: 3,
    poor: 4
  }
  def preprocessing_params
    {
      normalize: normalize,
      gamma: gamma,
      median_filter: median_filter,
      resize: resize,
      rotate: rotate,
      sharpen: sharpen,
      threshold: threshold
    }
  end
end