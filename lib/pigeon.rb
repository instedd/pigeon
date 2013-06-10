require "pigeon/errors"
require "pigeon/engine"

module Pigeon
  class Config
    attr_accessor :application_name
    attr_accessor :nuntium_host, :nuntium_account, :nuntium_app, :nuntium_app_password
    attr_accessor :verboice_host, :verboice_account, :verboice_password
    attr_accessor :verboice_default_call_flow

    attr_accessor :twitter_consumer_key, :twitter_consumer_secret

    def nuntium_configured?
      nuntium_host.present? && nuntium_account.present? && nuntium_app.present? && nuntium_app_password.present?
    end

    def verboice_configured?
      verboice_host.present? && verboice_account.present? && verboice_password.present?
    end

    def twitter_configured?
      twitter_consumer_key.present? && twitter_consumer_secret.present?
    end
  end

  def self.config
    @config ||= Config.new
  end

  def self.setup &block
    yield self.config
  end

  def self.root
    File.expand_path '../..', __FILE__
  end
end
