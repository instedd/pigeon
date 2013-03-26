module Pigeon
  class Engine < ::Rails::Engine
    isolate_namespace Pigeon

    initializer 'pigeon.load_helpers' do |app|
      ActiveSupport.on_load :action_controller do
        helper Pigeon::TagHelper
        helper Pigeon::FormHelper
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
  end
end
