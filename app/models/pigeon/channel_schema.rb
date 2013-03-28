module Pigeon
  class ChannelSchema
    class << self
      def from_hash(type, hash)
        self.new type, hash["kind"], hash["humanized_name"], hash["attributes"]
      end

      def list_from_hash(type, hash)
        hash.map do |name, data|
          data["kind"] ||= name
          from_hash type, data
        end
      end
    end

    attr_reader :type, :kind, :humanized_name, :attribute_data, :layout_data

    def initialize(type, kind, humanized_name = nil, attributes = [], layout = [])
      @type = type
      @kind = kind
      @humanized_name = humanized_name || kind
      @attribute_data = attributes
      @layout_data = layout
    end

    def attributes
      @attributes ||= process_attributes(@attribute_data)
    end

    def known_attributes
      attributes.keys
    end

    def user_attributes
      filtered_map_attributes(attributes) do |attr, prefixed_name|
        attr.user_editable ? prefixed_name : nil
      end
    end

    def default_values
      Hash[filtered_map_attributes(attributes) do |attr, prefixed_name|
        attr.default_value.nil? ? nil : [prefixed_name, attr.default_value]
      end]
    end

    def layout
      @layout ||= process_layout(@layout_data)
    end

  private

    def filtered_map_attributes(attributes, prefix = '', &block)
      attributes.inject([]) do |result, (name, attr)|
        name = "#{prefix}#{name}"
        if attr.is_a? Hash
          value = filtered_map_attributes(attr, "#{name}/", &block)
          result + value
        else
          value = block.call(attr, name)
          result + [value].reject(&:nil?)
        end
      end
    end

    def process_attributes(attributes)
      Hash[attributes.map do |attr|
        name = attr["name"]
        if attr["attributes"].present?
          attribute = process_attributes(attr["attributes"])
        else
          type = attr["type"] || "string"
          default_value = attr["default_value"] || attr["value"]
          label = attr["label"]
          humanized_name = attr["humanized_name"]
          if label.present?
            humanized_name ||= label
          elsif humanized_name.present?
            label ||= humanized_name
          else
            label = name
            humanized_name = label
          end
          tooltip = attr["tooltip"]
          user_editable = attr["user"].nil? ? true : attr["user"]
          attribute = Pigeon::ChannelAttribute.new(name, type, default_value, 
                                                   humanized_name, label, 
                                                   tooltip, user_editable)
        end
        [name, attribute]
      end].with_indifferent_access
    end

    def process_layout(layout)
      layout
    end
  end
end
