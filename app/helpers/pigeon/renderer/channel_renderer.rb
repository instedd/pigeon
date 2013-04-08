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
        if %w(@f @l @a).include?(v.first)
          render_attribute_command(v)
        elsif %w(@layout @wizard @page @raw).include?(v.first)
          render_layout_command(v)
        else
          super
        end
      end

      def render_attribute_command(v)
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
          ''
        end
      end

      def render_layout_command(v)
        if v[1].is_a? Hash
          options = v[1]
          content = v.drop(2)
          options = options.inject({}) do |options, (key, value)|
            if %w(class style).include?(key.to_s)
              options[key] = value
            else
              options["data-#{key.to_s}"] = value
            end
            options
          end
        else
          options = {}
          content = v.drop(1)
        end
        if %w(@wizard @layout).include?(v.first)
          options["data-scope"] ||= scope if scope.present?
        end

        case v.first
        when '@wizard'
          render ["div.pigeon.pigeon_wizard", options] + content
        when '@page'
          render ["div.pigeon_wizard_page", options] + content
        when '@layout'
          render ["div.pigeon.pigeon_layout", options] + content
        when '@raw'
          content.join.html_safe
        else
          ''
        end
      end
    end
  end
end

