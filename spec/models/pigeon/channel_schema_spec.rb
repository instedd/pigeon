require 'spec_helper'

module Pigeon
  describe ChannelSchema do
    before(:each) do
      @schema = ChannelSchema.from_hash 'nuntium', test_schema_hash('foobar')
    end

    context "on initialization" do
      it "should validate the presence of type" do
        expect do
          ChannelSchema.new '', 'foo'
        end.to raise_error(ArgumentError)
      end

      it "should validate the presence of kind" do
        expect do
          ChannelSchema.new 'foo', ''
        end.to raise_error(ArgumentError)
      end
    end

    describe "from_hash" do
      it "should set the type and kind" do
        expect(@schema.type).to eq('nuntium')
        expect(@schema.kind).to eq('foobar')
      end
    end

    it "should return only first level attributes as known_attributes" do
      expect(@schema.known_attributes.sort).to eq(%w(protocol ticket_code configuration).sort)
    end

    it "should list user attributes including nested ones" do
      expect(@schema.user_attributes.sort).to eq(%w(ticket_code configuration[user] configuration[password] configuration[port] configuration[send_offline]).sort)
    end

    it "should build a hash with default values, including nested attributes" do
      values = @schema.default_values
      expect(values.count).to eq(2)
      expect(values.keys.sort).to eq(%w(configuration protocol).sort)
      expect(values['protocol']).to eq('foobar')
      expect(values['configuration']).to be_a_kind_of(Hash)
      expect(values['configuration']['port']).to eq(5222)
    end

    it "should find shallow attributes" do
      expect(@schema.find_attribute('protocol')).not_to be_nil
      expect(@schema.find_attribute('protocol').name).to eq('protocol')
    end

    it "should find nested attributes" do
      expect(@schema.find_attribute('configuration[port]')).not_to be_nil
      expect(@schema.find_attribute('configuration[port]').name).to eq('port')
    end

    it "nested attributes should have a scope" do
      expect(@schema.find_attribute('configuration[port]').scope).not_to be_nil
      expect(@schema.find_attribute('configuration[port]').scoped_name).
        to eq('configuration[port]')
    end
  end
end
