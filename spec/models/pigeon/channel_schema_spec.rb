require 'spec_helper'

module Pigeon
  describe ChannelSchema do
    before(:each) do
      data = YAML::load_file(File.join(TEST_DATA_PATH, 'test_schemas.yml'))
      @schema = ChannelSchema.from_hash 'nuntium', data['foobar']
    end

    it "should return only first level attributes as known_attributes" do
      @schema.known_attributes.sort.should eq(%w(protocol ticket_code configuration).sort)
    end

    it "should list user attributes including nested ones" do
      @schema.user_attributes.sort.should eq(%w(ticket_code configuration[user] configuration[password] configuration[port] configuration[send_offline]).sort)
    end

    it "should build a hash with default values, including nested attributes" do
      values = @schema.default_values
      values.count.should eq(2)
      values.keys.sort.should eq(%w(configuration protocol).sort)
      values['protocol'].should eq('foobar')
      values['configuration'].should be_a_kind_of(Hash)
      values['configuration']['port'].should eq(5222)
    end

    it "should find shallow attributes" do
      @schema.find_attribute('protocol').should_not be_nil
      @schema.find_attribute('protocol').name.should eq('protocol')
    end

    it "should find nested attributes" do
      @schema.find_attribute('configuration[port]').should_not be_nil
      @schema.find_attribute('configuration[port]').name.should eq('port')
    end

    it "nested attributes should have a scope" do
      @schema.find_attribute('configuration[port]').scope.should_not be_nil
      @schema.find_attribute('configuration[port]').scoped_name.
        should eq('configuration[port]')
    end
  end
end
