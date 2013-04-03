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

    def initialize(type, kind, humanized_name = nil, attributes = [], layout = nil)
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
      flattened_map_filter(attributes) do |attr, prefixed_name|
        attr.user_editable ? prefixed_name : nil
      end
    end

    def default_values
      recursive_map_filter(attributes, &:default_value)
    end

    def layout
      @layout ||= @layout_data ? process_layout(@layout_data) : default_layout
    end

    def type_kind
      "#{type}/#{kind}"
    end

    def default_layout
      [".pigeon_layout"] + user_attributes.map do |attr_name|
        ["@f", attr_name]
      end
    end

  private

    # recursive map-filter of the channel schema attributes
    def flattened_map_filter(attributes, prefix = '', &block)
      attributes.inject([]) do |result, (name, attr)|
        name = "#{prefix}#{name}"
        if attr.is_a? Hash
          value = flattened_map_filter(attr, "#{name}/", &block)
          result + value
        else
          value = yield(attr, name)
          result + [value].reject(&:nil?)
        end
      end
    end

    def recursive_map_filter(attributes, &block)
      attributes.inject({}) do |result, (name, attr)|
        if attr.is_a? Hash
          value = recursive_map_filter(attr, &block)
        else
          value = yield(attr)
        end
        result[name] = value if value.present?
        result
      end
    end

    def process_attributes(attributes)
      Hash[attributes.map do |attr|
        name = attr["name"]
        if attr["attributes"].present?
          # recursively process nested attributes
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