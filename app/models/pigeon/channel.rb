module Pigeon
  class Channel
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include NestedScopes

    class << self
      def i18n_scope
        :pigeon
      end

      def type() nil end

      def schemas
        []
      end

      def find_type(type)
        begin 
          "Pigeon::#{type.to_s.capitalize}Channel".constantize
        rescue
          nil
        end
      end

      def find_schema(kind)
        schemas.find { |s| s.kind == kind }
      end

      def channel_accessor(*names)
        options = names.extract_options!

        names.each do |name|
          reader, line = "def #{name}; attributes['#{name}']; end", __LINE__
          writer, line = "def #{name}=(value); attributes['#{name}'] = value; end", __LINE__

          class_eval reader, __FILE__, line unless options[:instance_reader] == false
          class_eval writer, __FILE__, line unless options[:instance_writer] == false
        end
      end

      def list
        raise NotImplementedError
      end

      def find(*arguments)
        scope = arguments.slice!(0)
        options = arguments.slice!(0) || {}

        case scope
        when :all
          list.map { |id| find_single(id) }
        when :first
          find_single(list.first)
        when :last
          find_single(list.first)
        else
          find_single(scope)
        end
      end

      def all()   find(:all)   end
      def first() find(:first) end
      def last()  find(:last)  end

    private

      def find_single(id)
        raise NotImplementedError
      end
    end

    attr_reader :attributes
    attr_accessor :schema

    channel_accessor :name, :kind

    validates_presence_of :name, :kind

    def type
      self.class.type
    end

    def initialize(attrs = {}, persisted = false)
      @errors = ChannelErrors.new(self)
      @attributes = {}.with_indifferent_access
      @persisted = persisted
      @destroyed = false
      
      attrs = attrs.dup
      @schema = attrs.delete(:schema) || self.class.find_schema(attrs[:kind])
      attrs[:kind] ||= @schema.kind unless @schema.nil?

      load_default_values
      load_schema_defaults
      
      load(attrs)
    end

    def read_attribute_for_validation(key)
      attributes[key]
    end

    def persisted?
      @persisted
    end

    def new_record?
      !persisted?
    end

    def destroyed?
      @destroyed
    end

    alias :id :name
    alias :id= :name=

    def known_attributes
      schema.try(:known_attributes) || []
    end

    def method_missing(method_symbol, *arguments)
      method_name = method_symbol.to_s

      if method_name =~ /(=|\?)$/
        case $1
        when "="
          attributes[$`] = arguments.first
        when "?"
          attributes[$`]
        end  
      else 
        return attributes[method_name] if attributes.include?(method_name)
        # not set right now but we know about it
        return nil if known_attributes.include?(method_name)
        super
      end  
    end  

    def generate_name
      "#{kind || 'channel'}-#{Time.now.strftime('%Y%m%d%H%M%S%3N')}"
    end

    def generate_name!
      self.name = generate_name
    end

    def [](key)
      attributes[key]
    end

    def []=(key, value)
      attributes[key] = value
    end

    def read_attribute(attr_name)
      find_attr_recursive(attr_name, attributes)
    end

    def write_attribute(attr_name, value)
      hash, key = find_attr_ref_recursive(attr_name, attributes)
      hash && hash[key] = value
    end

    def assign_attributes(new_attributes)
      return if new_attributes.blank?

      new_attributes = new_attributes.stringify_keys
      new_attributes.each do |key, value|
        if value.is_a?(Hash)
          write_attribute(key, read_attribute(key).merge(value))
        else
          write_attribute(key, value)
        end
      end
    end

    def attributes=(new_attributes)
      return unless new_attributes.is_a?(Hash)
      assign_attributes(new_attributes)
    end

    def human_attribute_name(attr_name, options = {})
      (!schema.nil? && schema.find_attribute(attr_name).try(:humanized_name)) || 
        self.class.human_attribute_name(attr_name, options)
    end

    def save
      raise NotImplementedError
    end

    def save!
      save || raise(ChannelInvalid.new(self))
    end

    def destroy
      raise NotImplementedError
    end

  private

    def load_default_values
    end

    def load_schema_defaults
      load schema.default_values unless schema.nil?
    end

    def load(attributes)
      (attributes || {}).each do |key, value|
        @attributes[key.to_s] = case value
                                  when Hash
                                    (@attributes[key.to_s] || {}).merge(value)
                                  else
                                    value.duplicable? ? value.dup : value
                                  end
      end
    end
  end
end

