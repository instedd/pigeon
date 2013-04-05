module Pigeon
  module Renderer
    class ChannelRenderer < Base
      include ActionView::Helpers::CaptureHelper
      include ActionView::Helpers::FormHelper
      include Pigeon::ChannelHelper

      attr_accessor :output_buffer
      attr_accessor :channel, :scope

      def initialize(channel = nil, scope = nil)
        self.channel = channel
        self.scope = scope
      end

      def render_at_command(v)
        name = v[1]
        if v[2].is_a?(Hash)
          options = v[2].with_indifferent_access
        else
          options = {}
        end
        options[:scope] = scope if scope.present?

        case v.first
        when '@f'
          pigeon_render_channel_attribute_field(channel, name, options)
        when '@l'
          pigeon_render_channel_attribute_label(channel, name, options)
        when '@a'
          pigeon_render_channel_attribute(channel, name, options)
        else
          super
        end
      end
    end
  end
end

