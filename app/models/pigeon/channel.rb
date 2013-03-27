module Pigeon
  class Channel
    extend ActiveModel::Translation

    attr_reader :kind, :errors
    attr_accessor :name

    def self.from_type(type)
      "Pigeon::#{type.to_s.capitalize}Channel".constantize
    end

    def channel_kind
      ChannelKind.from_type(channel_type).from_kind(kind)
    end

    def initialize(kind)
      @kind = kind
      @name = randomize_name
      @new_channel = true
      @errors = ActiveModel::Errors.new(self)
    end

    def valid?
      @errors.empty?
    end

    def new_channel?
      @new_channel
    end

    def get_attribute(name)
      if self.respond_to?(name)
        self.send(name)
      else
        nil
      end
    end

    def assign_attributes(attributes)
      attributes.each do |attr, value|
        if self.respond_to?("#{attr.to_s}=")
          self.send("#{attr.to_s}=", value)
        end
      end
    end

    def save
      false
    end

    def save!
      raise ActiveRecord::RecordInvalid, self unless save
    end

    def destroy
    end

    private

    def randomize_name
      "#{@kind}-#{Time.now.strftime('%Y%m%d%H%M%S%3N')}"
    end
  end
end

