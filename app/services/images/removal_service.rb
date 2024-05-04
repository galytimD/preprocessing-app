
module Images
  class RemovalService
    def initialize(images)
      @images = images
    end

    def call
      @images.each do |image|
        remove_image_file(image)
        image.destroy 
      end
    end

    private

    def remove_image_file(image)
      file_path = Rails.root.join('public', 'downloads', image.path)
      File.delete(file_path) if File.exist?(file_path)
    rescue StandardError => e
      Rails.logger.error "Failed to delete image file: #{e.message}"
    end
  end
end