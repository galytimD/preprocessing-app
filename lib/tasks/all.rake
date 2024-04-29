# frozen_string_literal: true

namespace :all do
  desc 'Run all custom rake tasks in order'
  task run: [:environment, 'gd:download', 'ds:create'] do
    puts 'All custom tasks have been run in order.'
  end
end
