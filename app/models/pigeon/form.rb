module Pigeon
  class Form
    attr_reader :fields, :channel_kind

    def initialize(kind)
      @channel_kind = kind
      @fields = []
    end

    def <<(new_field)
      @fields << new_field
    end

    def default_values
      result = {}
      @fields.each do |f|
        result[f.name] = f.default_value unless f.default_value.nil?
      end
      result
    end

    def [](name)
      @fields.find { |f| f.name == name.to_s }
    end
  end
end
