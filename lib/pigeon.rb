require "pigeon/errors"
require "pigeon/engine"

module Pigeon
  class Config
    attr_accessor :nuntium_host, :nuntium_account, :nuntium_app, :nuntium_app_password
    attr_accessor :verboice_host, :verboice_account, :verboice_password
  end

  def self.config
    @config ||= Config.new
  end

  def self.setup &block
    block.call self.config
  end

  def self.root
    File.expand_path '../..', __FILE__
  end
end
