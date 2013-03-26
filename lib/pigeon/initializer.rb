module PigeonConfig
  NuntiumChannelKinds = YAML::load_file(File.join Pigeon.root, 'config/nuntium_channel_kinds.yml')
  VerboiceChannelKinds = YAML::load_file(File.join Pigeon.root, 'config/verboice_channel_kinds.yml')
end

