module Pigeon
  class VerboiceChannelKind < ChannelKind
    def self.all
      (@@kinds ||= load_channel_kinds).values
    end

    def self.from_kind(kind)
      (@@kinds ||= load_channel_kinds)[kind]
    end

    def self.load_channel_kinds
      Hash[PigeonConfig::VerboiceChannelKinds.map do |name, data|
        kind = VerboiceChannelKind.new(name: name, 
                                       display_name: data["display_name"],
                                       fields: data["fields"])
        [name, kind]
      end].with_indifferent_access
    end

    def build_channel(attributes = {})
      channel = VerboiceChannel.new name
      channel.update_attributes(form.default_values.merge(attributes))
      channel
    end
  end
end

