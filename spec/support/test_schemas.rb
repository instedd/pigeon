def test_schema_list
  YAML::load_file(File.join(TEST_DATA_PATH, 'test_schemas.yml'))
end

def test_schema_hash(key)
  data = test_schema_list
  raise ArgumentError, "#{key} schema not defined for testing" \
    unless data.include?(key)
  data[key]['kind'] = key
  data[key]
end

