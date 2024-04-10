Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "broadcast_messages#index"
  resources :broadcast_messages do
    member {post :send_sms}
  end
  resources :users
end
