module Pigeon
  module TagHelper
    def pigeon_verboice_channel_kinds_for_select
      options_for_select(VerboiceChannelKind.all.map do |c|
        [c.display_name, c.name]
      end)
    end

    def pigeon_nuntium_channel_kinds_for_select
      options_for_select(NuntiumChannelKind.all.map do |c|
        [c.display_name, c.name]
      end)
    end

    def pigeon_channel_kinds_for_select
      grouped_options_for_select({
        "Voice Channel" => VerboiceChannelKind.all.map do |c|
          [c.display_name, "verboice/#{c.name}"]
        end, 
        "Message Channel" => NuntiumChannelKind.all.map do |c|
          [c.display_name, "nuntium/#{c.name}"]
        end
      })
    end
  end
end
