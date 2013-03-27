module Pigeon
  class ChannelKind
    attr_reader :name, :display_name

    def self.from_type(type)
      "Pigeon::#{type.to_s.capitalize}ChannelKind".constantize
    end

    def self.from_type_and_kind(type_kind)
      type, kind = type_kind.split('/')
      begin from_type(type).from_kind(kind) rescue nil end
    end

    def type_and_kind
      "#{self.type.to_s}/#{self.name}"
    end

    def kind
      name
    end

    def form
      @form ||= build_form
    end

    def build_channel(attributes = {})
      raise TypeError, "abstract class"
    end

    protected

    def build_form
      form = Form.new self
      (@form_data || []).each do |field_data|
        field_data = field_data.with_indifferent_access
        field_name = field_data.delete("name")
        field_type = field_data.delete("type")
        form << Field.new(field_name, field_type, field_data)
      end
      form
    end

    def initialize(attributes = {})
      @name = attributes[:name]
      @display_name = attributes[:display_name]
      @form_data = attributes[:fields]
    end
  end
end

