module Pigeon
  class VerboiceChannel < ::Pigeon::Channel

    class << self
      def type() :verboice end

      def schemas
        @schemas ||= load_schemas
      end

      def list
        verboice.list_channels
      end

      def verboice
        @verboice ||= ::Pigeon::Verboice.from_config
      end

    private

      def find_single(id)
        new verboice.channel(id), true
      end

      def load_schemas
        Pigeon::ChannelSchema.list_from_hash(:verboice, PigeonConfig::VerboiceChannelSchemas)
      end
    end

    channel_accessor :call_flow, :config

    validates_presence_of :call_flow

    def limit
      config[:limit].to_i || 1
    end

    def save
      return false unless valid?

      begin
        if !persisted?
          self.class.verboice.create_channel attributes
          @persisted = true
        else
          self.class.verboice.update_channel attributes
        end
        true
      rescue Pigeon::VerboiceException => e
        Rails.logger.warn "error saving Verboice channel: #{e.message}"
        e.properties.each do |name, message|
          if attributes.include? name
            errors.add name, message
          elsif config.include? name
            errors.add "config[#{name}]", message
          else
            errors.add :base, "#{name} #{message}"
          end
        end
        false
      end
    end

    def destroy
      if !destroyed?
        begin
          if persisted?
            self.class.verboice.delete_channel(name)
          end
          @destroyed = true
        rescue Pigeon::VerboiceException => e
          Rails.logger.warn "error deleting Verboice channel: #{e.message}"
        end
      end
    end

  protected

    def load_default_values
      self.config = {}
      self.call_flow = Pigeon.config.verboice_default_call_flow
    end

  end
end
