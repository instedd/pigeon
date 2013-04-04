module Pigeon
  class ChannelAttribute < NestedAttribute
    attr_reader :type, :default_value, :humanized_name, :label, :tooltip, :user_editable, :options
    attr_writer :scope

    def initialize(name, type, options = {})
      raise ArgumentError, "invalid name" unless name.present?
      raise ArgumentError, "invalid type #{type}" unless self.class.valid_type?(type)

      @name = name
      @type = type.to_sym
      options = options.with_indifferent_access

      @default_value = options['default_value'] || options['value']
      @humanized_name = options['humanized_name'] || options['display']
      @label = options['label']
      if @label.present?
        @humanized_name ||= @label
      elsif @humanized_name.present?
        @label ||= @humanized_name
      else
        @label = name.to_s.humanize
        @humanized_name = @label
      end
      @tooltip = options['tooltip']
      @user_editable = options['user'].nil? ? true : options['user']
      @options = options['options'] || []
    end

    def self.valid_type?(type)
      %w(string boolean password enum integer timezone).include?(type.to_s)
    end
  end
end
