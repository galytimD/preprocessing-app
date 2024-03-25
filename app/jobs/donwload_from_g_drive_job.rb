require 'rake'

class DonwloadFromGDriveJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Гарантируем, что Rake окружение и задачи загружены
    Rake.load_rakefile(Rails.root.join('Rakefile'))

    # Вызов Rake задачи
    Rake::Task['all:run_in_order'].invoke

  # Перехватываем и логируем исключения, чтобы не прерывать цикл задач
  rescue StandardError => e
    puts "Произошла ошибка при выполнении Rake задачи: #{e.message}"
  ensure
    # Убедитесь, что задача может быть вызвана повторно
    Rake::Task['all:run_in_order'].reenable if Rake::Task.task_defined?('all:run_in_order')
  end
end
