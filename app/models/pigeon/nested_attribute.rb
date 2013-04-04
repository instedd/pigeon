module Pigeon
  class NestedAttribute
    attr_reader :name, :scope

    def initialize(name, scope = nil)
      @name = name
      @scope = scope
    end

    def scoped_name(prefix = nil)
      if scope.nil?
        if prefix.present?
          "#{prefix}[#{name}]"
        else
          name
        end
      else
        "#{scope.scoped_name(prefix)}[#{name}]"
      end
    end
  end
end

