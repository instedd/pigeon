module Pigeon
  class ChannelSchema
    include NestedScopes

    class << self
      def from_hash(type, hash)
        self.new type, hash["kind"], hash["humanized_name"], hash["attributes"], hash["template"]
      end

      def list_from_hash(type, hash)
        hash.map do |name, data|
          data["kind"] ||= name
          from_hash type, data
        end
      end
    end

    attr_reader :type, :kind, :humanized_name, :attribute_data, :template_data

    def initialize(type, kind, humanized_name = nil, attributes = [], template = nil)
      raise ArgumentError, "type cannot be blank" if type.blank?
      raise ArgumentError, "kind cannot be blank" if kind.blank?

      @type = type
      @kind = kind
      @humanized_name = humanized_name || kind
      @attribute_data = attributes
      @template_data = template
    end

    def attributes
      @attributes ||= process_attributes(@attribute_data)
    end

    def known_attributes
      attributes.keys
    end

    def user_attributes
      flattened_map_filter(attributes) do |attr|
        attr.user_editable ? attr.scoped_name : nil
      end
    end

    def default_values
      recursive_map_filter(attributes, &:default_value)
    end

    def template
      @template ||= @template_data ? process_template(@template_data) : default_template
    end

    def type_kind
      "#{type}/#{kind}"
    end

    def default_template
      ["@template"] + user_attributes.map do |attr_name|
        ["@attr", attr_name]
      end
    end

    def find_attribute(name)
      find_attr_recursive(name, attributes)
    end

  private

    # recursive map-filter of the channel schema attributes
    def flattened_map_filter(attributes, &block)
      attributes.inject([]) do |result, (name, attr)|
        if attr.is_a? Hash
          value = flattened_map_filter(attr, &block)
          result + value
        else
          value = yield(attr)
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

    def process_attributes(attributes, scope = nil)
      Hash[attributes.map do |attr|
        name = attr["name"]
        if attr["attributes"].present?
          # recursively process nested attributes
          attribute = process_attributes(attr["attributes"], NestedAttribute.new(name, scope))
        else
          type = attr["type"] || "string"
          attribute = Pigeon::ChannelAttribute.new(name, type, attr)
          attribute.scope = scope
        end
        [name, attribute]
      end].with_indifferent_access
    end

    def process_template(template)
      template
    end
  end
end
