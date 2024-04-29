require 'exifr/jpeg'
module Images
  class ImageMetadataExtractor
    def self.extract(image_path)
      jpeg = EXIFR::JPEG.new(image_path)

      if jpeg.exif?
        {
          coordinates: format_gps_data(jpeg.gps),
          resolution: format_resolution(jpeg.width, jpeg.height),
          orientation: format_orientation(jpeg.orientation)
        }
      else
        {
          coordinates: nil,
          resolution: nil,
          orientation: nil
        }
      end
    end

    private

    def self.format_gps_data(gps)
      if gps && gps.latitude && gps.longitude
        "#{sprintf('%.10f', gps.latitude)}, #{sprintf('%.10f', gps.longitude)}"
      else
        nil
      end
    end

    def self.format_resolution(width, height)
      "#{width}x#{height}" if width && height
    end

    def self.format_orientation(orientation)
      orientation.to_i.to_s if orientation
    end
  end
end