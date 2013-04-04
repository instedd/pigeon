module Pigeon
  module ChannelHelper
    def pigeon_render_attribute_field_only(attribute, value = nil, scope = nil)
      field_name = attribute.scoped_name(scope)
      field_value = value || ''

      case attribute.type
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
      when :boolean
        check_box_tag(field_name, '1', field_value.present?)
      end
    end
  end
end
