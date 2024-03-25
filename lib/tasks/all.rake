# frozen_string_literal: true

namespace :all do
  desc 'Run all custom rake tasks in order'
  task run_in_order: [:environment, 'google_drive:download_files', 'datasets:create_from_folders'] do
    puts 'All custom tasks have been run in order.'
  end
end
