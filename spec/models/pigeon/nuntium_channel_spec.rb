require 'spec_helper'

module Pigeon
  describe NuntiumChannel do
    describe "basic attributes" do
      before(:each) do
        @channel = NuntiumChannel.new
      end

      it "should be of nuntium type" do
        expect(@channel.type).to be(:nuntium)
      end

      [:protocol, :enabled, :direction, :priority].each do |attr|
        it "should respond to #{attr} methods" do
          expect(@channel).to respond_to(attr)
          expect(@channel).to respond_to("#{attr}=")
        end
      end

      it "should have default values" do
        expect(@channel.protocol).not_to be_nil
        expect(@channel.enabled).to be_truthy
        expect(@channel.direction).to eq("bidirectional")
        expect(@channel.priority).to eq(100)
      end
    end

    it "should load static schemas" do
      expect(NuntiumChannel.schemas).not_to be_empty
      expect(NuntiumChannel.find_schema('pop3')).not_to be_nil
    end

    describe "when initialized with kind" do
      before(:each) do
        @channel = NuntiumChannel.new kind: 'xmpp'
      end

      it "should find schema" do
        expect(@channel.schema).not_to be_nil
      end

      it "should set schema's default values" do
        expect(@channel.protocol).to eq('xmpp')
      end

      it "should set nested default schema values" do
        expect(@channel.configuration['port']).to eq(5222)
      end
    end
  end
end

