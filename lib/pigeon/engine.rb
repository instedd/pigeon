module Pigeon
  class Engine < ::Rails::Engine
    isolate_namespace Pigeon

    initializer 'pigeon.load_helpers' do |app|
      ActiveSupport.on_load :action_controller do
        helper Pigeon::TagHelper
        helper Pigeon::TextHelper
        helper Pigeon::TemplateHelper
        helper Pigeon::ChannelHelper
      end
    end  

    initializer 'pigeon.nuntium_configuration' do |app|
      require 'pigeon/nuntium'
    end

    initializer 'pigeon.verboice_configuration' do |app|
      require 'pigeon/verboice'
    end

    initializer 'pigeon.default_channel_kinds' do |app|
      require 'pigeon/initializer'
    end

    config.generators do |g|
      g.test_framework :rspec, :view_specs => false
    end
  end
end
