require 'spec_helper'

module Pigeon
  describe Channel do
    it_behaves_like "ActiveModel"

    describe "common attributes" do
      before(:each) do
        @channel = Channel.new
      end

      it "should respond to type" do
        @channel.should respond_to(:type)
      end

      ['name', 'kind'].each do |name|
        it "should respond to #{name}" do
          @channel.should respond_to(name.to_sym)
          @channel.should respond_to("#{name}=".to_sym)
        end
      end
    end

    describe "default instantiation" do
      before(:each) do
        @channel = Channel.new
      end

      it "should be of nil type" do
        @channel.type.should be_nil
      end

      it "should not be persisted" do
        @channel.should_not be_persisted
      end
    end

    describe "with attributes" do
      before(:each) do
        @attributes = { kind: 'foo', name: 'bar', other: true }
        @channel = Channel.new @attributes
      end

      it "should set each attribute" do
        @attributes.each do |k,v|
          @channel.send(k.to_sym).should eq(v)
        end
      end
      
      it "should expose attributes through []" do
        @channel['kind'].should eq(@attributes[:kind])
        @channel['name'].should eq(@attributes[:name])
      end

      it "should allow writing attributes through []" do
        @channel['other'] = false
        @channel.other.should be_false
      end
    end

    describe "with nested attributes" do
      before(:each) do
        @config = { foo: 42, bar: 'baz' }
        @channel = Channel.new configuration: @config
      end

      it "should dup nested values" do
        @config.each do |k,v|
          @channel.configuration[k].should be(@config[k])
        end
        @channel.configuration.should_not be(@config)
      end

      it "should have indifferent access" do
        @config.each do |k,v|
          @channel.configuration[k.to_s].should be(@config[k])
          @channel.configuration[k.to_sym].should be(@config[k])
        end
      end

      it "load should merge hashes" do
        @channel.send(:load, { configuration: { hello: 'world' }})
        @channel.configuration[:foo].should eq(@config[:foo])
        @channel.configuration[:bar].should eq(@config[:bar])
        @channel.configuration[:hello].should eq('world')
      end
    end

    describe "validations" do
      before(:each) do
        @valid_attributes = { name: 'foo', kind: 'bar' }
        @channel = Channel.new @valid_attributes
      end

      it "should be valid with valid attributes" do
        @channel.should be_valid
      end

      it "should validate presence of name" do
        @channel.name = nil
        @channel.should_not be_valid
      end

      it "should validate presence of kind" do
        @channel.kind = nil
        @channel.should_not be_valid
      end
    end

    describe "types and schemas" do
      it "should find defined types" do
        %w(nuntium verboice).each do |type|
          Channel.find_type(type).should_not be_nil
          Channel.find_type(type.to_sym).should_not be_nil
          Channel.find_type(type).type.to_s.should eq(type)
        end
      end

      it "should return nil for undefined types" do
        Channel.find_type('foobar').should be_nil
      end

      context "when initialized with a schema" do
        before(:each) do
          @schema = ChannelSchema.from_hash 'nuntium', test_schema_hash('foobar')
        end

        it "should set the schema" do
          @channel = Channel.new schema: @schema
          @channel.schema.should be(@schema)
        end

        it "should set the kind if none is given" do
          @channel = Channel.new schema: @schema
          @channel.kind.should eq(@schema.kind)
        end

        it "should not override kind if one is given" do
          @channel = Channel.new schema: @schema, kind: 'dont_override'
          @channel.kind.should eq('dont_override')
        end

        it "should not set the schema as an attribute" do
          @channel = Channel.new schema: @schema
          @channel.attributes[:schema].should be_nil
        end
      end
    end

    describe "read and write attributes" do
      before(:each) do
        @channel = Channel.new foo: 42, bar: { baz: 1, pepe: 'hi' }
      end

      it "should read shallow and nested attributes" do
        @channel.read_attribute('foo').should eq(@channel.foo)
        @channel.read_attribute('bar[baz]').should eq(@channel.bar['baz'])
        @channel.read_attribute('bar[pepe]').should eq(@channel.bar['pepe'])
      end

      it "should write shallow and nested attributes" do
        @channel.write_attribute('foo', 33)
        @channel.foo.should eq(33)

        @channel.write_attribute('bar[pepe]', 'bye')
        @channel.bar['pepe'].should eq('bye')
      end
    end
  end
end

