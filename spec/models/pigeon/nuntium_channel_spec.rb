require 'spec_helper'

module Pigeon
  describe NuntiumChannel do
    describe "basic attributes" do
      before(:each) do
        @channel = NuntiumChannel.new
      end

      it "should be of nuntium type" do
        @channel.type.should be(:nuntium)
      end

      [:protocol, :enabled, :direction, :priority].each do |attr|
        it "should respond to #{attr} methods" do
          @channel.should respond_to(attr)
          @channel.should respond_to("#{attr}=")
        end
      end

      it "should have default values" do
        @channel.protocol.should_not be_nil
        @channel.enabled.should be_true
        @channel.direction.should eq("bidirectional")
        @channel.priority.should eq(100)
      end
    end

    it "should load static schemas" do
      NuntiumChannel.schemas.should_not be_empty
      NuntiumChannel.find_schema('pop3').should_not be_nil
    end

    describe "when initialized with kind" do
      before(:each) do
        @channel = NuntiumChannel.new kind: 'xmpp'
      end

      it "should find schema" do
        @channel.schema.should_not be_nil
      end

      it "should set schema's default values" do
        @channel.protocol.should eq('xmpp')
      end

      it "should set nested default schema values" do
        @channel.configuration['port'].should eq(5222)
      end
    end
  end
end

