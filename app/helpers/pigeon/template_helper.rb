module Pigeon
  module TemplateHelper
    def pigeon_render_template(template, &block)
      renderer = Renderer::Base.new
      renderer.delegate = block if block_given?
      renderer.render template
    end

    def pigeon_render_channel_template(channel, template = nil, scope = 'channel', &block)
      renderer = Renderer::ChannelRenderer.new channel, scope
      renderer.delegate = block if block_given?
      template ||= channel.schema.template
      renderer.render template
    end

    def pigeon_render_channel(channel, scope = 'channel')
      pigeon_render_channel_template(channel, nil, scope)
    end
  end
end
