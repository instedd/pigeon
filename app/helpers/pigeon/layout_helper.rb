module Pigeon
  module LayoutHelper
    def pigeon_render_layout_for(channel, name = 'channel')
      schema = channel.schema
      render_vector schema.layout do |args|
        at_cmnd = args.first
        case at_cmnd
        when "@f"
          field_name = args[1]
          attribute = schema.find_attribute(field_name)
          pigeon_render_attribute_field(attribute, name)
        else
          Rails.logger.warn "Unknown at-command #{at_cmnd}"
          return ''
        end
      end
    end

    def pigeon_field_name(name, scope = nil)
      if scope.nil?
        name
      else
        "#{scope}[#{name}]"
      end
    end

    def pigeon_render_attribute_field(attribute, scope_name = nil, value = nil)
      field_name = pigeon_field_name(attribute.name, scope_name)
      field_value = value || ''

      if attribute.type == :boolean
        result = check_box_tag(field_name, '1', field_value.present?)
        result << label_tag(field_name, attribute.label)
      else
        result = label_tag(field_name, attribute.label)
        result << tag(:br)
        result << case attribute.type
                    when :string
                      text_field_tag(field_name, field_value)
                    when :password
                      password_field_tag(field_name, field_value)
                    when :integer
                      number_field_tag(field_name, field_value)
                    when :enum
                      options = attribute.options
                      if options.length > 0 && options[0].is_a?(Hash)
                        options = options.map { |h| [h["display"], h["value"]] }
                      end
                      select_tag(field_name, options_for_select(options, field_value))
                    when :timezone
                      select_tag(field_name, time_zone_options_for_select(field_value))
                    end
      end
      result
    end

    def pigeon_render_vector(v, &delegate)
      return '' if v.empty?

      if v.first.starts_with? '@'
        if block_given?
          return yield(v)
        else
          return ''
        end
      end

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
            pigeon_render_vector(elt, &delegate)
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
