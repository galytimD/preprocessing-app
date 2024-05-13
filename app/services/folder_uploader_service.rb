class FolderUploaderService
  require_relative '../../app/services/google_drive/api'
  require 'google/apis/drive_v3'
  require 'googleauth'
  require 'fileutils'
  require 'concurrent'
  require 'json'
  attr_accessor :total_images 
  attr_reader :drive_api,:project_name
  Google::Apis.logger.level = Logger::ERROR
  def initialize(projectName = "Untitled project")
    @project_name= projectName  
    @drive_api = GoogleDrive::Api.new
    @total_images = 0
  end
  def upload_folder
    base_path = Rails.root.join('public', 'preprocessed')
    if Dir.empty?(base_path)
      puts "The preprocessed directory is empty."
      return "The preprocessed directory is empty."
    end
    drive_service = @drive_api.drive_service
    folder_datasets_id = Rails.application.credentials.dig(:google_drive, :folder_datasets_id)
  
    raise ArgumentError, 'Datasets folder ID is not configured in credentials' unless folder_datasets_id
  
    project_folder_id = find_or_create_folder(drive_service, project_name, folder_datasets_id)
    
    train_images_id = find_or_create_subfolders(drive_service, 'train', project_folder_id)
    val_images_id = find_or_create_subfolders(drive_service, 'val', project_folder_id)
    test_images_id = find_or_create_subfolders(drive_service, 'test', project_folder_id)
  
    
    train_images_path = base_path.join('train', 'images')
    val_images_path = base_path.join('val', 'images')
    test_images_path = base_path.join('test', 'images')
    create_local_dirs(train_images_path, base_path.join('train', 'labels'))
    create_local_dirs(val_images_path, base_path.join('val', 'labels'))
    create_local_dirs(test_images_path, base_path.join('test', 'labels'))
    distribute_files(base_path, train_images_path, val_images_path, test_images_path)  

    metadata_file_id = find_file_id(drive_service, project_folder_id, 'metadata.json')
    if metadata_file_id
      @drive_api.download_file(metadata_file_id, base_path.join('metadata.json').to_s)
      metadata_content = JSON.parse(File.read(base_path.join('metadata.json')))
      @total_images = metadata_content["total_images"] || 0 
    end
    
    
    upload_folders_in_parallel(drive_service, {
      train: { id: train_images_id, path: train_images_path },
      val: { id: val_images_id, path: val_images_path },
      test: { id: test_images_id, path: test_images_path }
    })

    metadata_path = create_metadata(base_path, @total_images, project_folder_id)
    drive_service.delete_file(metadata_file_id) if metadata_file_id
    upload_file(drive_service, project_folder_id, metadata_path.to_s)
    File.delete(metadata_path) if File.exist?(metadata_path)

    remove_empty_dirs(base_path.join('train'))
    remove_empty_dirs(base_path.join('val'))
    remove_empty_dirs(base_path.join('test'))
  
    puts "All folders uploaded successfully."
    return "All folders uploaded successfully."
  end
  
  def find_file_id(service, parent_id, file_name)
    response = service.list_files(q: "name = '#{file_name}' and '#{parent_id}' in parents", spaces: 'drive', fields: 'files(id, name)', page_size: 10)
    file = response.files.first
    file ? file.id : nil
  end
  

  def find_or_create_folder(service, name, parent_id)
    response = service.list_files(q: "name = '#{name}' and '#{parent_id}' in parents and mimeType = 'application/vnd.google-apps.folder'", spaces: 'drive', fields: 'files(id, name)', page_size: 10)
    folder = response.files.first
    if folder
       folder.id 
    else 
      folder = create_folder(service, name, parent_id)
      puts "created folder #{name}"
      folder
    end
  end

  def create_folder(service, name, parent_id)
    folder_metadata = { name: name, mime_type: 'application/vnd.google-apps.folder', parents: [parent_id] }
    folder = service.create_file(folder_metadata, fields: 'id')
    folder.id
  end

  def find_or_create_subfolders(service, name, parent_id)
    folder_id = find_or_create_folder(service, name, parent_id)
    find_or_create_folder(service, 'images', folder_id)
  end

  def create_local_dirs(*paths)
    paths.each { |path| FileUtils.mkdir_p(path) unless Dir.exist?(path) }
  end

  def distribute_files(source_dir, train_images_dir, val_images_dir, test_images_dir)
    files = Dir.children(source_dir).select { |file| File.file?(File.join(source_dir, file)) }.shuffle
    train_size, val_size = (files.size * 0.65).round, (files.size * 0.15).round
    move_files(files.first(train_size), source_dir, train_images_dir)
    move_files(files.slice(train_size, val_size), source_dir, val_images_dir)
    move_files(files.last(files.size - train_size - val_size), source_dir, test_images_dir)
  end

  def move_files(files, source_dir, dest_dir)
    files.each { |file| FileUtils.mv(File.join(source_dir, file), dest_dir) }
  end

  def create_metadata(base_path, total_images, project_folder_id)
    metadata = { "data_type" => "image", "total_images" => total_images, "classes" => ["healthy"], "url" => "https://drive.google.com/drive/folders/#{project_folder_id}" }
    metadata_path = base_path.join('metadata.json')
    File.write(metadata_path, JSON.pretty_generate(metadata))
    metadata_path
  end

  def upload_folders_in_parallel(service, folders)
    folders.each do |type, info|
      Concurrent::Promise.execute { upload_folder_recursive(service, info[:id], info[:path]) }.wait
    end
  end

  def upload_folder_recursive(service, parent_id, folder_path)
    Dir.foreach(folder_path) do |item|
      next if ['.', '..'].include?(item)
      file_path = File.join(folder_path, item)
      if File.directory?(file_path)
        new_folder_id = find_or_create_folder(service, item, parent_id)
        upload_folder_recursive(service, new_folder_id, file_path)
      else
        upload_file_if_not_exists(service, parent_id, file_path)
      end
    end
    remove_empty_dirs(folder_path)
  end

  def remove_empty_dirs(path)
    Dir.glob("#{path}/**/*").reverse_each { |sub_path| FileUtils.rmdir(sub_path) if Dir.exist?(sub_path) && Dir.empty?(sub_path) }
    FileUtils.rmdir(path) if Dir.exist?(path) && Dir.empty?(path)
  end

  def upload_file_if_not_exists(service, parent_id, file_path)
    file_name = File.basename(file_path)
    image_record = Image.find_by(name: file_name)
  
    if image_record && image_record.uploaded
      puts "file already uploaded"
      File.delete(file_path) if File.exist?(file_path)
    else
      upload_file(service, parent_id, file_path)
      @total_images +=1
      image_record.update(uploaded: true) if image_record
      File.delete(file_path) if File.exist?(file_path)
    end
  end
  
  
  def file_exists?(service, parent_id, file_name)
    response = service.list_files(q: "name = '#{file_name}' and '#{parent_id}' in parents", spaces: 'drive', fields: 'files(id, name)', page_size: 10)
    response.files.any?
  end

  def upload_file(service, parent_id, file_path)
    file_metadata = { name: File.basename(file_path), parents: [parent_id] }
    service.create_file(file_metadata, fields: 'id', upload_source: file_path, content_type: 'application/octet-stream')
    puts "Uploaded #{File.basename(file_path)}"
  end
end