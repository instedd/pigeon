Pigeon::Engine.routes.draw do
  get 'twitter' => 'twitter#begin'
  get 'twitter/callback' => 'twitter#callback'

  get 'twilio/get_incoming_phone_numbers' => 'twilio#get_incoming_phone_numbers'
end
