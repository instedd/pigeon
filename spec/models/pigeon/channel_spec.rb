require 'spec_helper'

module Pigeon
  describe Channel do
    it_behaves_like "ActiveModel"

    describe "common attributes" do
      before(:each) do
        @channel = Channel.new
      end

      it "should respond to type" do
        expect(@channel).to respond_to(:type)
      end

      ['name', 'kind'].each do |name|
        it "should respond to #{name}" do
          expect(@channel).to respond_to(name.to_sym)
          expect(@channel).to respond_to("#{name}=".to_sym)
        end
      end
    end

    describe "default instantiation" do
      before(:each) do
        @channel = Channel.new
      end

      it "should be of nil type" do
        expect(@channel.type).to be_nil
      end

      it "should not be persisted" do
        expect(@channel).not_to be_persisted
      end
    end

    describe "with attributes" do
      before(:each) do
        @attributes = { kind: 'foo', name: 'bar', other: true }
        @channel = Channel.new @attributes
      end

      it "should set each attribute" do
        @attributes.each do |k,v|
          expect(@channel.send(k.to_sym)).to eq(v)
        end
      end
      
      it "should expose attributes through []" do
        expect(@channel['kind']).to eq(@attributes[:kind])
        expect(@channel['name']).to eq(@attributes[:name])
      end

      it "should allow writing attributes through []" do
        @channel['other'] = false
        expect(@channel.other).to be_falsey
      end
    end

    describe "with nested attributes" do
      before(:each) do
        @config = { foo: 42, bar: 'baz' }
        @channel = Channel.new configuration: @config
      end

      it "should dup nested values" do
        @config.each do |k,v|
          expect(@channel.configuration[k]).to be(@config[k])
        end
        expect(@channel.configuration).not_to be(@config)
      end

      it "should have indifferent access" do
        @config.each do |k,v|
          expect(@channel.configuration[k.to_s]).to be(@config[k])
          expect(@channel.configuration[k.to_sym]).to be(@config[k])
        end
      end

      it "load should merge hashes" do
        @channel.send(:load, { configuration: { hello: 'world' }})
        expect(@channel.configuration[:foo]).to eq(@config[:foo])
        expect(@channel.configuration[:bar]).to eq(@config[:bar])
        expect(@channel.configuration[:hello]).to eq('world')
      end
    end

    describe "validations" do
      before(:each) do
        @valid_attributes = { name: 'foo', kind: 'bar' }
        @channel = Channel.new @valid_attributes
      end

      it "should be valid with valid attributes" do
        expect(@channel).to be_valid
      end

      it "should validate presence of name" do
        @channel.name = nil
        expect(@channel).not_to be_valid
      end

      it "should validate presence of kind" do
        @channel.kind = nil
        expect(@channel).not_to be_valid
      end
    end

    describe "types and schemas" do
      it "should find defined types" do
        %w(nuntium verboice).each do |type|
          expect(Channel.find_type(type)).not_to be_nil
          expect(Channel.find_type(type.to_sym)).not_to be_nil
          expect(Channel.find_type(type).type.to_s).to eq(type)
        end
      end

      it "should return nil for undefined types" do
        expect(Channel.find_type('foobar')).to be_nil
      end

      context "when initialized with a schema" do
        before(:each) do
          @schema = ChannelSchema.from_hash 'nuntium', test_schema_hash('foobar')
        end

        it "should set the schema" do
          @channel = Channel.new schema: @schema
          expect(@channel.schema).to be(@schema)
        end

        it "should set the kind if none is given" do
          @channel = Channel.new schema: @schema
          expect(@channel.kind).to eq(@schema.kind)
        end

        it "should not override kind if one is given" do
          @channel = Channel.new schema: @schema, kind: 'dont_override'
          expect(@channel.kind).to eq('dont_override')
        end

        it "should not set the schema as an attribute" do
          @channel = Channel.new schema: @schema
          expect(@channel.attributes[:schema]).to be_nil
        end
      end
    end

    describe "read and write attributes" do
      before(:each) do
        @channel = Channel.new foo: 42, bar: { baz: 1, pepe: 'hi' }
      end

      it "should read shallow and nested attributes" do
        expect(@channel.read_attribute('foo')).to eq(@channel.foo)
        expect(@channel.read_attribute('bar[baz]')).to eq(@channel.bar['baz'])
        expect(@channel.read_attribute('bar[pepe]')).to eq(@channel.bar['pepe'])
      end

      it "should write shallow and nested attributes" do
        @channel.write_attribute('foo', 33)
        expect(@channel.foo).to eq(33)

        @channel.write_attribute('bar[pepe]', 'bye')
        expect(@channel.bar['pepe']).to eq('bye')
      end

      it "should return nil when reading unexisting attribute" do
        expect(@channel.read_attribute('fnord')).to be_nil
        expect(@channel.read_attribute('fnord[foo]')).to be_nil
        expect(@channel.read_attribute('foo[fnord]')).to be_nil
        expect(@channel.read_attribute('bar[fnord]')).to be_nil
      end

      it "should ignore writes to unexisting attributes" do
        expect(@channel.write_attribute('fnord[foo]', 5)).to be_nil
        expect(@channel.write_attribute('foo[fnord]', 5)).to be_nil
        expect(@channel.write_attribute('bar[fnord][blah]', 5)).to be_nil
      end
    end

    describe "attributes assignment" do
      before(:each) do
        @channel = Channel.new foo: 42, bar: { baz: 1, pepe: 'hi' }
      end

      it "should assign shallow attributes" do
        @channel.assign_attributes(foo: 123)
        expect(@channel.foo).to eq(123)
      end

      it "should assign nested attributes" do
        @channel.assign_attributes(bar: { baz: 42 })
        expect(@channel.bar[:baz]).to eq(42)
      end

      it "should assign scoped attributes" do
        @channel.assign_attributes('bar[baz]' => 42)
        expect(@channel.bar[:baz]).to eq(42)
      end
    end
  end
end

