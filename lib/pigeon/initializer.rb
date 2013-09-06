module PigeonConfig
  @@nuntium_channel_schemas = {}
  @@verboice_channel_schemas = {}

  def self.reload_schemas()
    @@nuntium_channel_schemas.replace load_schemas(File.join Pigeon.root, 'config/schemas/nuntium')
    @@verboice_channel_schemas.replace load_schemas(File.join Pigeon.root, 'config/schemas/verboice')
  end

  def self.load_schemas(path)
    schemas = {}
    Dir.glob(File.join(path, '*.yml')).each do |f|
      schemas.update(YAML::load_file(f))
    end
    schemas
  end

  if Rails.env.development?
    def self.nuntium_channel_schemas
      reload_schemas
      @@nuntium_channel_schemas
    end

    def self.verboice_channel_schemas
      reload_schemas
      @@verboice_channel_schemas
    end
  else
    def self.nuntium_channel_schemas
      @@nuntium_channel_schemas
    end

    def self.verboice_channel_schemas
      @@verboice_channel_schemas
    end
  end
end

