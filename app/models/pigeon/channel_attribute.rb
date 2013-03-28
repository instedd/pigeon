module Pigeon
  class ChannelAttribute
    attr_reader :name, :type, :default_value, :humanized_name, :label, :tooltip, :user_editable, :validations

    def initialize(name, type, default_value = nil, humanized_name = nil, label = nil, tooltip = nil, user_editable = true)
      raise TypeError, "invalid type #{type}" unless self.class.valid_type?(type)
      @name = name
      @type = type.to_sym
      @default_value = default_value
      @humanized_name = humanized_name
      @label = label
      @tooltip = tooltip
      @user_editable = user_editable
    end

    def self.valid_type?(type)
      %w(string boolean password enum integer timezone).include?(type.to_s)
    end
  end
end
