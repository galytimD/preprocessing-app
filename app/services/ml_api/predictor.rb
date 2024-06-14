require 'rest-client'

module MlApi
  class Predictor
    def self.send_images
      url = 'https://16ca-185-16-28-64.ngrok-free.app/predict/detection_no_image'
      image_directory = Rails.root.join('public', 'downloads', 'dataset__1')
      image_paths = Dir[image_directory.join('*')].select { |file| File.file?(file) && ['.jpg', '.jpeg', '.png'].include?(File.extname(file).downcase) }

      # Вывод названий всех файлов в директории
      puts "Files in directory:"
      image_paths.each { |path| puts File.basename(path) }

      results = []

      image_paths.each do |image_path|
        attempt = 0
        max_attempts = 3
        begin
          attempt += 1
          f = File.new(image_path, 'rb')
          mime_type = case File.extname(image_path).downcase
                      when '.jpg', '.jpeg'
                        'image/jpeg'
                      when '.png'
                        'image/png'
                      else
                        'application/octet-stream'
                      end

          response = RestClient::Request.execute(
            method: :post,
            url: url,
            payload: {
              images: f,
              multipart: true
            },
            headers: {
              content_type: mime_type
            },
            timeout: 120
          )

          body = JSON.parse(response.body) rescue response.body
          results << body
          f.close

        rescue RestClient::ExceptionWithResponse => e
          puts "An error occurred while processing #{image_path}: #{e.message}"
          body = JSON.parse(e.response.body) rescue e.response.body
          results << body
        rescue RestClient::Exceptions::OpenTimeout, RestClient::Exceptions::ReadTimeout, Errno::ECONNRESET => e
          if attempt < max_attempts
            puts "Retrying #{image_path} due to #{e.message} (attempt #{attempt}/#{max_attempts})"
            sleep(2 ** attempt) # Используем экспоненциальную задержку перед повторной попыткой
            retry
          else
            puts "Failed to process #{image_path} after #{max_attempts} attempts due to #{e.message}"
            results << { file: File.basename(image_path), error: e.message, backtrace: e.backtrace.join("\n") }
          end
        rescue => e
          puts "An error occurred while processing #{image_path}: #{e.message}"
          results << { file: File.basename(image_path), error: e.message, backtrace: e.backtrace.join("\n") }
        ensure
          f.close if f
        end
      end

      results
    end
  end
end