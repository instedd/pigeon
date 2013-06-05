# Provides access to the Nuntium Public API.
# Taken from the nuntium-api-ruby gem version 0.21
# See http://bitbucket.org/instedd/nuntium-api-ruby

require 'net/http'
require 'json'
require 'rest_client'
require 'cgi'
require 'pigeon/errors'
require 'pigeon/utils'

module Pigeon
  class Nuntium
    include Pigeon::Utils

    def self.error_class
      Pigeon::NuntiumException
    end

    def self.from_config
      config = Pigeon.config

      Nuntium.new config.nuntium_host, config.nuntium_account, config.nuntium_app, config.nuntium_app_password
    end

    # Creates an application-authenticated Nuntium api access.
    def initialize(url, account, application, password)
      @url = url
      @account = account
      @application = application
      @options = {
        :user => "#{account}/#{application}",
        :password => password,
        :headers => {:content_type => 'application/json'},
      }
    end

    # Gets the list of countries known to Nuntium as an array of hashes.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def countries
      get_json "/api/countries.json"
    end

    # Gets a country as a hash given its iso2 or iso3 code, or nil if a country with that iso does not exist.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def country(iso)
      get_json "/api/countries/#{iso}.json"
    end

    # Gets the list of carriers known to Nuntium that belong to a country as an array of hashes, given its
    # iso2 or iso3 code. Gets all carriers as an array of hashes if no country is specified.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def carriers(country_id = nil)
      if country_id
        get_json "/api/carriers.json?country_id=#{country_id}"
      else
        get_json "/api/carriers.json"
      end
    end

    # Gets a carrier as a hash given its guid, or nil if a carrier with that guid does not exist.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def carrier(guid)
      get_json "/api/carriers/#{guid}.json"
    end

    # Returns the list of channels belonging to the application or that don't
    # belong to any application, as an array of hashes.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def channels
      get "/api/channels.json" do |response, error|
        raise ::Pigeon::NuntiumException.new error.message if error

        channels = JSON.parse response.body
        channels.map! do |channel|
          read_configuration channel
          with_indifferent_access channel
        end
        channels
      end
    end

    # Returns a channel given its name. Raises when the channel does not exist.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def channel(name)
      get("/api/channels/#{name}.json") do |response, error|
        raise ::Pigeon::NuntiumException.new error.message if error

        channel = JSON.parse response.body
        read_configuration channel
        with_indifferent_access channel
      end
    end

    # Creates a channel.
    #
    #   create_channel :name => 'foo', :kind => 'qst_server', :protocol => 'sms', :configuration => {:password => 'bar'}
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong. You can access specific errors on properties via the properties
    # accessor of the exception.
    def create_channel(channel)
      channel = channel.dup

      write_configuration channel
      post "/api/channels.json", channel.to_json do |response, error|
        handle_channel_error error if error

        channel = JSON.parse response.body
        read_configuration channel
        with_indifferent_access channel
      end
    end

    # Updates a channel.
    #
    #   update_channel :name => 'foo', :kind => 'qst_server', :protocol => 'sms', :configuration => {:password => 'bar'}
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong. You can access specific errors on properties via the properties
    # accessor of the exception.
    def update_channel(channel)
      channel = channel.dup

      write_configuration channel
      channel_name = channel['name'] || channel[:name]

      put "/api/channels/#{channel_name}.json", channel.to_json do |response, error|
        handle_channel_error error if error

        channel = JSON.parse response.body
        read_configuration channel
        with_indifferent_access channel
      end
    end

    # Deletes a chnanel given its name.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def delete_channel(name)
      delete "/api/channels/#{name}" do |response, error|
        raise ::Pigeon::NuntiumException.new error.message if error

        response
      end
    end

    # Returns the list of candidate channels when simulating routing the given AO message.
    #
    #   candidate_channels_for_ao :from => 'sms://1', :to => 'sms://2', :subject => 'hello', :body => 'hi!'
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def candidate_channels_for_ao(message)
      get_channels "/api/candidate/channels.json?#{to_query message}"
    end

    # Sends one or many AO messages.
    #
    # To send a token, just include it in the message as :token => 'my_token'
    #
    #   send_ao :from => 'sms://1', :to => 'sms://2', :subject => 'hello', :body => 'hi!'
    #   send_ao [{:from => 'sms://1', :to => 'sms://2', :subject => 'hello', :body => 'hi!'}, {...}]
    #
    # Returns a hash with :id, :guid and :token keys if a single message was sent, otherwise
    # returns a hash with a :token key.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def send_ao(messages)
      if messages.is_a? Array
        post "/#{@account}/#{@application}/send_ao.json", messages.to_json do |response, error|
          raise ::Pigeon::NuntiumException.new error.message if error

          with_indifferent_access({:token => response.headers[:x_nuntium_token]})
        end
      else
        get "/#{@account}/#{@application}/send_ao?#{to_query messages}" do |response, error|
          raise ::Pigeon::NuntiumException.new error.message if error

          with_indifferent_access(
            {
              :id => response.headers[:x_nuntium_id],
              :guid => response.headers[:x_nuntium_guid],
              :token => response.headers[:x_nuntium_token],
            }
          )
        end
      end
    end

    # Gets AO messages that have the given token. The response is an array of hashes with the messages' attributes.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def get_ao(token)
      get_json "/#{@account}/#{@application}/get_ao.json?token=#{token}"
    end

    # Gets the custom attributes specified for a given address. Returns a hash with the attributes
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def get_custom_attributes(address)
      get_json "/api/custom_attributes?address=#{address}"
    end

    # Sets custom attributes of a given address.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def set_custom_attributes(address, attributes)
      post "/api/custom_attributes?address=#{address}", attributes.to_json do |response, error|
        raise ::Pigeon::NuntiumException.new error.message if error

        nil
      end
    end


    # Creates a friendship between the channel's twitter account and the given user.
    # Returns the response from twitter.
    # Refer to Twitter's documentation: https://dev.twitter.com/docs/api/1/post/friendships/create
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def twitter_friendship_create(channel_name, user, follow = true)
      get("/api/channels/#{channel_name}/twitter/friendships/create?user=#{CGI.escape user}&follow=#{follow}") do |response, error|
        raise ::Pigeon::NuntiumException.new error.message if error

        response
      end
    end

    # Returns a URL to authorize the given twitter channel, which will eventually redirect
    # to the given callback URL.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def twitter_authorize(channel_name, callback)
      get_text("/api/channels/#{channel_name}/twitter/authorize?callback=#{CGI.escape callback}")
    end

    # Adds an xmpp conact to the xmpp account associated to the given channel.
    #
    # Raises ::Pigeon::NuntiumException if something goes wrong.
    def xmpp_add_contact(channel_name, jid)
      get("/api/channels/#{channel_name}/xmpp/add_contact?jid=#{CGI.escape jid}") do |response, error|
        raise ::Pigeon::NuntiumException.new error.message if error

        response
      end
    end

    private

    def write_configuration(channel)
      return unless channel[:configuration] || channel['configuration']

      configuration = []
      (channel[:configuration] || channel['configuration']).each do |name, value|
        configuration << {:name => name, :value => value}
      end
      if channel[:configuration]
        channel[:configuration] = configuration
      else
        channel['configuration'] = configuration
      end
    end

    def read_configuration(channel)
      channel['configuration'] = Hash[channel['configuration'].map { |e| [e['name'], e['value']] }]
    end

    def get_text(path)
      get(path) do |response, error|
        raise ::Pigeon::NuntiumException.new error.message if error

        response.body
      end
    end

    def get_channels(path)
      get(path) do |response, error|
        raise ::Pigeon::NuntiumException.new error.message if error

        channels = JSON.parse response.body
        channels.map! do |channel|
          read_configuration channel
          with_indifferent_access channel
        end
        channels
      end
    end

  end
end

