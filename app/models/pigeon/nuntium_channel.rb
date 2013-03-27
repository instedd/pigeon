module Pigeon
  class NuntiumChannel < Channel
    attr_accessor :protocol, :priority, :direction, :enabled, :configuration

    def channel_type
      :nuntium
    end

    def initialize(*)
      super

      @direction = 'bidirectional'
      @priority = 100
      @enabled = true
      @configuration = {}
    end

    def direction=(dir)
      if ["incoming", "outgoing", "bidirectional"].include? dir
        @direction = dir
      else
        raise TypeError, "invalid direction #{dir}"
      end
    end

    def enabled?
      @enabled
    end

    def get_attribute(name)
      if AttributesAsStrings.include? name.to_s
        self.send(name.to_s)
      else
        @configuration[name]
      end
    end

    def assign_attributes(attributes)
      attributes.each do |attr, value|
        if AttributesAsStrings.include? attr.to_s
          self.send("#{attr.to_s}=", value)
        else
          @configuration[attr] = value
        end
      end
    end

    def save
      @errors.clear
      begin
        if new_channel?
          nuntium.create_channel nuntium_params
          @new_channel = false
        else
          nuntium.update_channel nuntium_params
        end
        true
      rescue Nuntium::Exception => e
        e.properties.each do |name, message|
          @errors.add name, message
        end
        false
      end
    end

    def destroy
      if !new_channel?
        begin
          nuntium.delete_channel(name)
        rescue Nuntium::Exception => e
          puts e
        end
      end
    end

    def self.list
      nuntium.channels.map do |data|
        data['name']
      end
    end

    def self.find(name)
      from_data nuntium.channel(name)
    end

    def assign_from_data(data)
      @new_channel = false

      Attributes.each do |attr|
        self.send("#{attr.to_s}=", data[attr])
      end
      assign_attributes(data[:configuration])
      self
    end

    def filtered_configuration
      form = channel_kind.form
      configuration.reject { |k,v|
        form[k].type == :password && v.blank?
      }
    end

    private

    Attributes = [:name, :protocol, :direction, :enabled, :priority]
    AttributesAsStrings = Attributes.map(&:to_s)

    def self.nuntium
      Nuntium.from_config
    end

    def nuntium
      @nuntium ||= Nuntium.from_config
    end

    def nuntium_params
      { 
        name: name, 
        kind: kind, 
        protocol: protocol,
        direction: direction, 
        enabled: enabled,
        priority: priority, 
        configuration: filtered_configuration
      }
    end

    def self.from_data(data)
      NuntiumChannel.new(data[:kind]).assign_from_data(data)
    end
  end
end

