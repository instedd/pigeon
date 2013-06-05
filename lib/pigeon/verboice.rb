# Provides access to the Verboice Public API.
# Taken from verboice-api-ruby gem version 0.7.0
# See http://bitbucket.org/instedd/verboice-api-ruby
#

require 'net/http'
require 'json'
require 'rest_client'
require 'cgi'
require 'time'
require 'pigeon/errors'
require 'pigeon/utils'

module Pigeon
  class Verboice
    include Pigeon::Utils

    def self.error_class
      Pigeon::VerboiceException
    end

    def self.from_config
      config = Pigeon.config

      self.new config.verboice_host, config.verboice_account, config.verboice_password
    end

    # Creates an account-authenticated Verboice api access.
    def initialize(url, account, password, default_channel = nil)
      @url = url
      @account = account
      @password = password
      @default_channel = default_channel
      @options = {
        :user => account,
        :password => password,
        :headers => {:content_type => 'application/json'},
      }
    end

    def call address, options = {}
      options = options.dup

      args = {}
      if channel = options.delete(:channel)
        args[:channel] = channel
      else
        args[:channel] = @default_channel
      end

      args[:address] = address

      if not_before = options.delete(:not_before)
        args[:not_before] = not_before.iso8601
      end

      flow = options.delete(:flow)
      callback_url = options.delete(:callback_url)

      args.merge!(options)

      if flow
        post "/api/call?#{to_query args}", flow do |response, error|
          raise ::Pigeon::VerboiceException.new error.message if error
          JSON.parse response.body
        end
      else
        args[:callback_url] = callback_url if callback_url
        get_json "/api/call?#{to_query args}"
      end
    end

    def call_state id
      get_json "/api/calls/#{id}/state"
    end

    def call_redirect id
      get_json "/api/calls/#{id}/redirect"
    end

    def channel(name)
      get("/api/channels/#{name}.json") do |response, error|
        handle_channel_error error if error

        channel = JSON.parse response.body
        with_indifferent_access channel
      end
    end

    def create_channel(channel)
      post "/api/channels.json", channel.to_json do |response, error|
        handle_channel_error error if error

        channel = JSON.parse response.body
        with_indifferent_access channel
      end
    end

    def update_channel(channel, name = channel['name'])
      put "/api/channels/#{name}.json", channel.to_json do |response, error|
        handle_channel_error error if error

        channel = JSON.parse response.body
        with_indifferent_access channel
      end
    end

    # Deletes a channel given its name.
    #
    # Raises Verboice::Exception if something goes wrong.
    def delete_channel(name)
      delete "/api/channels/#{name}" do |response, error|
        raise ::Pigeon::VerboiceException.new error.message if error

        response
      end
    end

    def list_channels()
      get_json "/api/channels.json"
    end

    def schedules(project_id)
      get_json "/api/projects/#{project_id}/schedules.json"
    end

    def schedule(project_id, name)
      get_json "/api/projects/#{project_id}/schedules/#{name}.json"
    end

    def create_schedule(project_id, schedule)
      post "/api/projects/#{project_id}/schedules", schedule.to_json do |response, error|
        raise ::Pigeon::VerboiceException.new error.message if error
        response
      end
    end

    def update_schedule(project_id, name, schedule)
      put "/api/projects/#{project_id}/schedules/#{name}", schedule.to_json do |response, error|
        raise ::Pigeon::VerboiceException.new error.message if error
        response
      end
    end

    def delete_schedule(project_id, name)
      delete "/api/projects/#{project_id}/schedules/#{name}" do |response, error|
        raise ::Pigeon::VerboiceException.new error.message if error
        response
      end
    end

  end
end

