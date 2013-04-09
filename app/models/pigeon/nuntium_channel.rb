module Pigeon
  class NuntiumChannel < Channel

    class << self
      def type() :nuntium end

      def schemas
        @schemas ||= load_schemas
      end

      def list
        nuntium.channels.map do |data|
          data['name']
        end
      end

      def nuntium
        @nuntium ||= Nuntium.from_config
      end

    private

      def find_single(id)
        new nuntium.channel(id), true
      end

      def load_schemas
        Pigeon::ChannelSchema.list_from_hash(:nuntium, PigeonConfig::NuntiumChannelSchemas)
      end
    end

    channel_accessor :direction, :priority, :protocol, :enabled, :configuration
    channel_accessor :restrictions, :at_rules, :ao_rules

    validates_numericality_of :priority, only_integer: true
    validates_presence_of :protocol
    validates_inclusion_of :direction, 
      :in => %w(incoming outgoing bidirectional),
      :message => "must be incoming, outgoing or bidirectional"

    def save
      return false unless valid?

      begin
        if !persisted?
          self.class.nuntium.create_channel attributes
          @persisted = false
        else
          self.class.nuntium.update_channel attributes
        end
        true
      rescue Nuntium::Exception => e
        Rails.logger.warn "error saving Nuntium channel: #{e.message}"
        e.properties.each do |name, message|
          if attributes.include? name
            errors.add name, message
          elsif configuration.include? name
            errors.add "configuration[#{name}]", message
          else
            errors.add :base, "#{name} #{message}"
          end
        end
        false
      end
    end

    def save!
      save || raise(ChannelInvalid.new(self))
    end

    def destroy
      if !destroyed?
        begin
          if persisted?
            self.class.nuntium.delete_channel(name)
          end
          @destroyed = true
        rescue Nuntium::Exception => e
          puts e
        end
      end
    end

  protected

    def load_default_values
      self.protocol = 'sms'
      self.priority = 100
      self.enabled = true
      self.direction = 'bidirectional'
      self.configuration = {}
    end

  end
end

