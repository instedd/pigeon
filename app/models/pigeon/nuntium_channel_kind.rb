module Pigeon
  class NuntiumChannelKind < ChannelKind
    attr_reader :protocol

    def self.all
      (@@kinds ||= load_channel_kinds).values
    end

    def self.from_kind(kind)
      (@@kinds ||= load_channel_kinds)[kind]
    end

    def self.load_channel_kinds
      Hash[PigeonConfig::NuntiumChannelKinds.map do |name, data|
        kind = NuntiumChannelKind.new(name: name, 
                                      display_name: data["display_name"], 
                                      fields: data["fields"],
                                      protocol: data["protocol"])
        [name, kind]
      end].with_indifferent_access
    end

    def build_channel(attributes = {})
      channel = NuntiumChannel.new name
      channel.protocol = protocol
      channel.update_attributes(form.default_values.merge(attributes))
      channel
    end

    protected

    def initialize(attributes = {})
      super(attributes)
      @protocol = attributes[:protocol]
    end
  end
end


