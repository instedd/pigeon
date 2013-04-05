module Pigeon
  module Renderer
    class Base
      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::TagHelper

      attr_accessor :delegate

      def render(v)
        return '' if v.empty?

        if v.first.starts_with? '@'
          render_at_command(v)
        else
          render_vector(v)
        end
      end

      def render_at_command(v)
        if delegate.present? && delegate.respond_to?(:call)
          delegate.call(v)
        else
          ''
        end
      end

      def render_vector(v)
        tag_name, options = parse_tag_name(v.first)
        content = v.drop(1)
        if content.first.is_a? Hash
          options.update(content.first.with_indifferent_access) do |key, oldval, newval|
            case key.to_s
            when "id"
              oldval
            when "class"
              oldval + " " + newval
            else
              newval
            end
          end
          content = content.drop(1)
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
    end
  end
end

