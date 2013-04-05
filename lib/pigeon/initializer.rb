module PigeonConfig
  def self.load_schemas(path)
    schemas = {}
    Dir.glob(File.join(path, '*.yml')).each do |f|
      schemas.update(YAML::load_file(f))
    end
    schemas
  end

  NuntiumChannelSchemas = load_schemas(File.join Pigeon.root, 'config/schemas/nuntium')
  VerboiceChannelSchemas = load_schemas(File.join Pigeon.root, 'config/schemas/verboice')
end

