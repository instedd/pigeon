module Pigeon
  class VerboiceChannel < Channel

    class << self
      def type() :verboice end

      def schemas
        @schemas ||= load_schemas
      end

      def list
        verboice.list_channels
      end

      def find(*arguments)
        raise NotImplementedError
      end

      def verboice
        @verboice ||= Verboice.from_config
      end

    private

      def load_schemas
        Pigeon::ChannelSchema.list_from_hash(:verboice, PigeonConfig::VerboiceChannelKinds)
      end
    end

    channel_accessor :call_flow

    def save
      raise NotImplementedError
    end

    def destroy
      raise NotImplementedError
    end
  end
end
