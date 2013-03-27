module Pigeon
  module TextHelper

    def channel_type_humanize(channel_type)
      case channel_type
      when :verboice
        "Voice channel"
      when :nuntium
        "Message channel"
      else
        "Unknown channel"
      end
    end

  end
end
