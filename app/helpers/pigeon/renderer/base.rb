module Pigeon
  module Renderer
    class Base
      include Sprockets::Helpers::RailsHelper
      include Sprockets::Helpers::IsolatedHelper
      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::AssetTagHelper

      class << self
        def handle(command, handler)
          @handlers ||= {}
          @handlers[command.to_s] = handler
        end

        def find_handler(command)
          @handlers ||= {}
          @handlers.fetch(command.to_s) do |command|
            if superclass.respond_to?(:find_handler)
              self.superclass.find_handler(command)
            else
              nil
            end
          end
        end
      end

      attr_accessor :delegate

      handle :raw, :render_raw
      handle :template, :render_template_command
      handle :wizard, :render_template_command
      handle :page, :render_template_command

      def render(v)
        return '' if v.empty?

        if v.first.starts_with? '@'
          render_at_command(v)
        else
          render_vector(v)
        end
      end

      def render_at_command(v)
        command = v.first[1..-1]
        handler = find_handler(command)
        if !handler.nil?
          dispatch_command_handler(handler, v)
        elsif delegate.present? && delegate.respond_to?(:call)
          delegate.call(v)
        else
          ''
        end
      end

      def extract_options(data)
        if data[1].is_a?(Hash)
          [data[0], data[1], data.drop(2)]
        else
          [data[0], {}, data.drop(1)]
        end
      end

      def render_vector(v)
        selector, user_options, content = extract_options(v)
        tag_name, options = parse_tag_name(selector)

        options.update(user_options.with_indifferent_access) do |key, oldval, newval|
          case key.to_s
          when "id"
            oldval
          when "class"
            oldval + " " + newval
          else
            newval
          end
        end

        if tag_name.downcase == 'img'
          if URI(path = options[:src]).relative?
            options[:src] = image_path(path)
          end
        end

        if content.empty?
          if %w(br meta img link script hr).include? tag_name.downcase
            tag tag_name, options
          else
            content_tag tag_name, '', options
          end
        else
          content_html = safe_join(content.map do |elt|
            case elt
            when Array
              render(elt)
            else
              elt
            end
          end)
          content_tag tag_name, content_html, options
        end
      end

      def render_raw(data)
        data.drop(1).join.html_safe
      end

      def render_template_command(v)
        command, options, content = extract_options(v)

        options = options.inject({}) do |options, (key, value)|
          if %w(class style).include?(key.to_s) || key.to_s.starts_with?('data-')
            options[key] = value
          else
            options["data-#{key.to_s}"] = value
          end
          options
        end
        if %w(@template @wizard).include?(command)
          options["data-application-name"] ||= Pigeon.config.application_name
          options["data-twitter-path"] = Pigeon::Engine.routes.url_helpers.twitter_path
        end

        case command
        when '@wizard'
          render ["div.pigeon.pigeon_wizard", options] + content
        when '@page'
          render ["div.pigeon_wizard_page", options] + content
        when '@template'
          render ["div.pigeon.pigeon_template", options] + content
        else
          ''
        end
      end

    private

      def parse_tag_name(input)
        tag_name = input.scan(/\A[^#.]*/).first
        tag_name = 'div' if tag_name.blank?
        options = {}.with_indifferent_access
        classes = []
        input.scan(/[#.][^#.]+/) do |tok|
          case tok.first
          when '#'
            options[:id] = tok[1..-1]
          when '.'
            classes << tok[1..-1]
          end
        end
        options[:class] = classes.join(' ') unless classes.empty?

        [tag_name, options]
      end

      def find_handler(command)
        self.class.find_handler(command)
      end

      def dispatch_command_handler(handler, data)
        if handler.is_a?(Symbol)
          self.send(handler, data)
        elsif handler.is_a?(Proc)
          handler.class(data)
        end
      end
    end
  end
end

