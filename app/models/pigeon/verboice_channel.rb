module Pigeon
  class VerboiceChannel < Channel
    attr_accessor :call_flow

    def channel_type
      :message
    end

    def save
      raise NotImplementedError
    end

    def destroy
      raise NotImplementedError
    end

    def self.list
      verboice.list_channels
    end

    def self.find(name)
      raise NotImplementedError
    end

    private

    def self.verboice
      Verboice.from_config
    end

    def verboice
      @verboice ||= Verboice.from_config
    end
  end
end
