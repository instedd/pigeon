module Pigeon
  class PigeonError < StandardError
  end

  class ChannelInvalid < PigeonError
    attr_reader :channel

    def initialize(channel)
      @channel = channel
    end
  end

  # Same as ActiveModel::Errors, except it calls human_attribute_name on the
  # instance instead of the class
  class ChannelErrors < ActiveModel::Errors
    def full_message(attribute, message)
      return message if attribute == :base
      attr_name = attribute.to_s.tr('.', '_').humanize
      attr_name = @base.human_attribute_name(attribute, :default => attr_name)                                                          
      I18n.t(:"errors.format", {
        :default   => "%{attribute} %{message}",
        :attribute => attr_name,
        :message   => message
      })  
    end 
  end
end

