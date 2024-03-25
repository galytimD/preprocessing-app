# frozen_string_literal: true

Rails.application.routes.draw do
  root 'datasets#index'
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :datasets, except: %i[new create] do
    collection do
      get :download_datasets
      get :preprocessing
    end
    resources :images, only: [] do
      collection do
        delete 'batch_destroy'
      end
    end
  end
end
