Pigeon::Engine.routes.draw do
  get 'twitter' => 'twitter#begin'
  get 'twitter/callback' => 'twitter#callback'
end
