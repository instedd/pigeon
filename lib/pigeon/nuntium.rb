require 'nuntium'

class Nuntium
  def self.from_config
    config = Pigeon.config

    Nuntium.new config.nuntium_host, config.nuntium_account, config.nuntium_app, config.nuntium_app_password
  end
end

