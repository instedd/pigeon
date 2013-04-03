module Pigeon
  module TagHelper
    def pigeon_verboice_channel_kinds_for_select
      options_for_select(pigeon_schema_options(VerboiceChannel.schemas))
    end

    def pigeon_nuntium_channel_kinds_for_select
      options_for_select(pigeon_schema_options(NuntiumChannel.schemas))
    end

    def pigeon_channel_kinds_for_select
      grouped_options_for_select({
        "Voice Channel" => 
          pigeon_schema_options(VerboiceChannel.schemas, 'verboice/'),
        "Message Channel" => 
          pigeon_schema_options(NuntiumChannel.schemas, 'nuntium/')
      })
    end

    def pigeon_schema_options(schemas, value_prefix = '')
      schemas.map do |c|
        [c.humanized_name, "#{value_prefix}#{c.kind}"]
      end
    end
  end
end
