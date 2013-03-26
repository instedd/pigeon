module Pigeon
  class Field
    VALID_TYPES = [:string, :integer, :password, :boolean, :enum, :timezone]

    attr_reader :name, :label, :type, :default_value, :options

    def initialize(name, type = nil, options = {})
      type ||= :string
      raise "Invalid field type" unless VALID_TYPES.map(&:to_s).include? type.to_s
      raise "Field name cannot be blank" unless name.present?

      @name = name
      @type = type.to_sym
      @default_value = options[:default_value]
      @label = options[:label] || name.to_s.humanize
      @options = options[:options] || []
    end
  end
end

