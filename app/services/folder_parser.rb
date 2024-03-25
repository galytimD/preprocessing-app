# frozen_string_literal: true

class FolderParser
  def self.folder_names(dataset_path)
    Dir.children(dataset_path).select do |entry|
      File.directory?(File.join(dataset_path, entry))
    end
  end
end
