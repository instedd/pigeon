module Pigeon
  class PigeonError < StandardError
  end

  class ChannelInvalid < PigeonError
    attr_reader :channel

    def initialize(channel)
      @channel = channel
      errors = @channel.errors.full_messages.join(", ")
      super(I18n.t(:"#{@channel.class.i18n_scope}.errors.messages.channel_invalid", :errors => errors, :default => :"errors.messages.channel_invalid"))
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

  class ApiException < PigeonError
    attr_accessor :properties

    def initialize(msg, properties = {})
      super msg
      @properties = properties
    end
  end
  
  class VerboiceException < ApiException
  end

  class NuntiumException < ApiException
  end

end

