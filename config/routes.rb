Rails.application.routes.draw do
  root 'index#index'
  get 'othello', to: 'othello#show', as: 'othello'
end
