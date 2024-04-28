Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:3000'  # Указывает, что разрешены запросы с вашего клиентского приложения React
    resource '*',  # Разрешает доступ ко всем ресурсам
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
     
  end
end
