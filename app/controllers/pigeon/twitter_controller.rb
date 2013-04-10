require 'twitter_oauth'

module Pigeon
  class TwitterController < ActionController::Base
    def begin
      client = new_twitter_client

      request_token = client.request_token(:oauth_callback => twitter_callback_url)
      session[:pigeon] ||= {}
      session[:pigeon][:twitter] = { 
        token: request_token.token, 
        secret: request_token.secret 
      }
      session[:pigeon][:js_callback] = params[:js_callback]
      redirect_to request_token.authorize_url
    end

    def callback
      if session[:pigeon].nil? || session[:pigeon][:twitter].nil?
        redirect_to twitter_url
      end

      client = new_twitter_client

      request_token = session[:pigeon][:twitter]
      @access_token = client.authorize(
        request_token[:token],
        request_token[:secret],
        :oauth_verifier => params[:oauth_verifier]
      )
      @callback = session[:pigeon][:js_callback] || 'pigeon_twitter_callback'
      @screen_name = client.info['screen_name']
    end

  private

    def new_twitter_client
      client = TwitterOAuth::Client.new(
        :consumer_key => Pigeon.config.twitter_consumer_key,
        :consumer_secret => Pigeon.config.twitter_consumer_secret
      )
    end
  end
end
