module Pigeon
  module ChannelHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::FormHelper
    include ActionView::Helpers::FormOptionsHelper

    def pigeon_render_attribute_field(attribute, value = nil, options = {})
      scope = options.delete(:scope)
      field_name = attribute.scoped_name(scope)
      field_value = value || ''
      forced_type = options.delete(:type)
      render_type = (forced_type || attribute.type).to_s

      case render_type
      when "string"
        text_field_tag(field_name, field_value, options)
      when "password"
        password_field_tag(field_name, field_value, options)
      when "integer"
        number_field_tag(field_name, field_value, options)
      when "enum"
        choices = attribute.options
        if choices.length > 0 && choices[0].is_a?(Hash)
          choices = choices.map { |h| [h["display"], h["value"]] }
        end
        select_tag(field_name, options_for_select(choices, field_value), options)
      when "timezone"
        select_tag(field_name, time_zone_options_for_select(field_value), options)
      when "boolean"
        check_box_tag(field_name, '1', field_value.present?, options)
      when "hidden"
        hidden_field_tag(field_name, field_value, options)
      else
        text_field_tag(field_name, field_value, 
                       { :type => render_type }.merge(options))
      end
    end

    def pigeon_render_attribute_label(attribute, options = {})
      return '' if attribute.type == :hidden
      scope = options.delete(:scope)
      field_name = attribute.scoped_name(scope)
      label_tag(field_name, attribute.label, options)
    end

    def pigeon_render_attribute(attribute, value = nil, options = {})
      scope = options.delete(:scope)
      field_with_errors = options.delete(:field_with_errors)
      content_tag :div, options do
        label = pigeon_render_attribute_label(attribute, scope: scope)
        field = pigeon_render_attribute_field(attribute, value, scope: scope)
        if field_with_errors.present?
          field = content_tag :div, field, :class => 'field_with_errors'
        end
        if attribute.type == :boolean
          safe_join([field, label])
        elsif attribute.type == :hidden
          field
        else
          safe_join([label, tag(:br), field])
        end
      end
    end

    def pigeon_render_channel_attribute_field(channel, attr_name, options = {})
      value = channel.read_attribute(attr_name)
      attribute = channel.schema.try(:find_attribute, attr_name)
      attribute ||= ChannelAttribute.build_default(attr_name, value)
      field = pigeon_render_attribute_field(attribute, value, options)
      if channel.errors.include?(attr_name.to_sym)
        content_tag :div, field, :class => 'field_with_errors'
      else
        field
      end
    end

    def pigeon_render_channel_attribute_label(channel, attr_name, options = {})
      attribute = channel.schema.try(:find_attribute, attr_name)
      attribute ||= ChannelAttribute.build_default(attr_name)
      pigeon_render_attribute_label(attribute, options)
    end

    def pigeon_render_channel_attribute(channel, attr_name, options = {})
      value = channel.read_attribute(attr_name)
      attribute = channel.schema.try(:find_attribute, attr_name)
      attribute ||= ChannelAttribute.build_default(attr_name, value)
      if channel.errors.include?(attr_name.to_sym)
        options[:field_with_errors] = true
      end
      pigeon_render_attribute(attribute, value, options)
    end
  end
end
