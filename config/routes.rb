Rails.application.routes.draw do
  root to: "pages#home"
  get 'jobs/scrape', to: 'jobs#scrape', as: 'scrape_jobs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :jobs
end
