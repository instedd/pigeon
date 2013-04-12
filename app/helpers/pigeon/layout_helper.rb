module Pigeon
  module LayoutHelper
    def pigeon_render_layout(layout, &block)
      renderer = Renderer::Base.new
      renderer.delegate = block if block_given?
      renderer.render layout
    end

    def pigeon_render_channel_layout(channel, layout = nil, scope = 'channel', &block)
      renderer = Renderer::ChannelRenderer.new channel, scope
      renderer.delegate = block if block_given?
      layout ||= channel.schema.layout
      renderer.render layout
    end
  end
end
