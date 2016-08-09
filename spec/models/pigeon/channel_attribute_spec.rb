require 'spec_helper'

module Pigeon
  describe ChannelAttribute do
    it "should require a name" do
      expect { ChannelAttribute.new nil, 'bar' }.to raise_error(ArgumentError)
      expect { ChannelAttribute.new '', 'bar' }.to raise_error(ArgumentError)
    end

    it "should require a type" do
      expect { ChannelAttribute.new 'foo', nil }.to raise_error(ArgumentError)
    end

    it "should validate type" do
      expect { ChannelAttribute.new 'foo', 'bar' }.to raise_error(ArgumentError)
    end

    it "should set label and humanized name by default" do
      @attr = ChannelAttribute.new 'foo', :string
      expect(@attr.label).not_to be_blank
      expect(@attr.humanized_name).not_to be_blank
    end

    it "should humanize label and humanized name by default" do
      @attr = ChannelAttribute.new 'some_field', :string
      expect(@attr.label).to eq('Some field')
      expect(@attr.humanized_name).to eq('Some field')
    end

    it "should set label from humanized name if not given" do
      @attr = ChannelAttribute.new 'foo', :string, humanized_name: 'bar'
      expect(@attr.label).to eq('bar')
      expect(@attr.humanized_name).to eq('bar')
    end

    it "should set humanized name from label if not given" do
      @attr = ChannelAttribute.new 'foo', :string, label: 'bar'
      expect(@attr.label).to eq('bar')
      expect(@attr.humanized_name).to eq('bar')
    end

    it "should initialize options to empty array" do
      @attr = ChannelAttribute.new 'foo', :enum
      expect(@attr.options).not_to be_nil
    end

    it "should have a scope" do
      @attr = ChannelAttribute.new 'foo', :string
      expect(@attr).to respond_to(:scope)
      expect(@attr).to respond_to(:scope=)
    end

    it "should compute its scoped name" do
      @foo = ChannelAttribute.new 'foo', :string
      @bar = ChannelAttribute.new 'bar', :string
      
      expect(@bar.scoped_name).to eq('bar')
      expect(@bar.scoped_name('bling')).to eq('bling[bar]')

      @bar.scope = @foo
      expect(@bar.scoped_name).to eq('foo[bar]')
      expect(@bar.scoped_name('bling')).to eq('bling[foo][bar]')
    end

    describe "build_default" do
      it "should create a valid string attribute by default" do
        attr = ChannelAttribute.build_default('foo')
        expect(attr).not_to be_nil
        expect(attr).to be_a(ChannelAttribute)
        expect(attr.type).to eq(:string)
        expect(attr.name).to eq('foo')
      end

      it "should create a boolean attribute if the value is boolean" do
        expect(ChannelAttribute.build_default('foo', true).type).to eq(:boolean)
        expect(ChannelAttribute.build_default('foo', false).type).to eq(:boolean)
      end

      it "should create an integer attribute if the value is an integer number" do
        expect(ChannelAttribute.build_default('foo', 10).type).to eq(:integer)
      end

      it "should build a scope if the attribute name is scoped" do
        attr = ChannelAttribute.build_default('foo[bar]')
        expect(attr.name).to eq('bar')
        expect(attr.scoped_name).to eq('foo[bar]')
        expect(attr.scoped_name('baz')).to eq('baz[foo][bar]')
      end

      it "should build a recursive scope if the attribute name is deeply nested" do
        attr = ChannelAttribute.build_default('baz[foo][bar]')
        expect(attr.name).to eq('bar')
        expect(attr.scoped_name).to eq('baz[foo][bar]')
        expect(attr.scoped_name('outer')).to eq('outer[baz][foo][bar]')
      end
    end
  end
end
