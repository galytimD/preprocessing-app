Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', '127.0.0.1:4000' # Указывает, что разрешены запросы с вашего клиентского приложения React
    resource '*',  # Разрешает доступ ко всем ресурсам
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
     
  end
end
