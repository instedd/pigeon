module Pigeon
  module Renderer
    class ChannelRenderer < ::Pigeon::Renderer::Base
      include Pigeon::ChannelHelper

      attr_accessor :output_buffer
      attr_accessor :channel, :scope

      handle :field, :render_attribute_command
      handle :label, :render_attribute_command
      handle :attr, :render_attribute_command
      handle :hidden, :render_attribute_command

      def initialize(channel = nil, scope = nil)
        self.channel = channel
        self.scope = scope
      end

      def render_attribute_command(v)
        command, options, content = extract_options(v)
        name = content.first
        options[:scope] = scope if scope.present?

        case command
        when '@field'
          pigeon_channel_attribute_field(channel, name, options)
        when '@label'
          pigeon_channel_attribute_label(channel, name, options)
        when '@attr'
          if options.include?(:class)
            options[:class] << ' pigeon_attribute'
          else
            options[:class] = 'pigeon_attribute'
          end
          pigeon_channel_attribute(channel, name, options)
        when '@hidden'
          options = options.update({ :type => :hidden })
          pigeon_channel_attribute_field(channel, name, options)
        else
          ''
        end
      end

      def render_template_command(v)
        command, options, content = extract_options(v)
        if %w(@wizard @template).include?(command)
          options["data-scope"] ||= scope if scope.present?
          options["data-persisted"] = channel.persisted?
          options["data-kind"] = channel.kind
          options["data-name"] = channel.name
        end
        super([command, options] + content)
      end

    end
  end
end

