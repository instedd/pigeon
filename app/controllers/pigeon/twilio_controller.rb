require 'twilio-ruby'

module Pigeon
  class TwilioController < ActionController::Base
    def get_incoming_phone_numbers
      account_sid = params[:account_sid].strip
      auth_token = params[:auth_token].strip

      client = Twilio::REST::Client.new account_sid, auth_token
      incoming_phones = client.account.incoming_phone_numbers.list
      json = incoming_phones.map do |phone|
        {
          sid: phone.sid,
          phone_number: phone.phone_number,
          friendly_name: phone.friendly_name,
        }
      end
      render json: json
    rescue Twilio::REST::RequestError => ex
      head :unauthorized
    end
  end
end
