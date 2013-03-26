module Pigeon
  module FormHelper
    def pigeon_render_form(form, name = "channel_data", channel = nil)
      result = raw ''
      form.fields.each do |field|
        field_name = "#{name}[#{field.name}]"
        field_value = channel && channel.get_attribute(field.name)
        result << content_tag(
          :p, pigeon_render_field(field, field_name, field_value),
          :class => (channel && channel.errors[field.name].empty?) ? 
          '' : 'field_with_errors')
      end
      result
    end

    def pigeon_render_field(field, field_name = nil, field_value = nil)
      field_name ||= field.name
      field_value = field_value || field.default_value || ''

      if field.type == :boolean
        result = check_box_tag(field_name, '1', field_value.present?)
        result << label_tag(field_name, field.label)
      else
        result = label_tag field_name, field.label
        result << tag(:br)
        result << case field.type
                    when :string
                      text_field_tag(field_name, field_value)
                    when :password
                      password_field_tag(field_name, field_value)
                    when :integer
                      number_field_tag(field_name, field_value)
                    when :enum
                      options = field.options
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
