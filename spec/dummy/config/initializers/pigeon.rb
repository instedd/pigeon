Pigeon.setup do |config|
  config.application_name = 'Test application'

  config.nuntium_host = 'http://nuntium.instedd.org'
  config.nuntium_account = 'ACCOUNT'
  config.nuntium_app = 'APP'
  config.nuntium_app_password = 'PASSWORD'

  config.verboice_host = 'http://verboice.instedd.org'
  config.verboice_account = 'ACCOUNT'
  config.verboice_password = 'PASSWORD'
  config.verboice_default_call_flow = 'Default Call Flow'

  #config.twitter_consumer_key = ''
  #config.twitter_consumer_secret = ''
end
