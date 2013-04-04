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
  end
end
