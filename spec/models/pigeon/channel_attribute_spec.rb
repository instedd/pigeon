require 'spec_helper'

module Pigeon
  describe ChannelAttribute do
    it "should require a name" do
      lambda { ChannelAttribute.new nil, 'bar' }.should raise_error(ArgumentError)
      lambda { ChannelAttribute.new '', 'bar' }.should raise_error(ArgumentError)
    end

    it "should require a type" do
      lambda { ChannelAttribute.new 'foo', nil }.should raise_error(ArgumentError)
    end

    it "should validate type" do
      lambda { ChannelAttribute.new 'foo', 'bar' }.should raise_error(ArgumentError)
    end

    it "should set label and humanized name by default" do
      @attr = ChannelAttribute.new 'foo', :string
      @attr.label.should_not be_blank
      @attr.humanized_name.should_not be_blank
    end

    it "should humanize label and humanized name by default" do
      @attr = ChannelAttribute.new 'some_field', :string
      @attr.label.should eq('Some field')
      @attr.humanized_name.should eq('Some field')
    end

    it "should set label from humanized name if not given" do
      @attr = ChannelAttribute.new 'foo', :string, humanized_name: 'bar'
      @attr.label.should eq('bar')
      @attr.humanized_name.should eq('bar')
    end

    it "should set humanized name from label if not given" do
      @attr = ChannelAttribute.new 'foo', :string, label: 'bar'
      @attr.label.should eq('bar')
      @attr.humanized_name.should eq('bar')
    end

    it "should initialize options to empty array" do
      @attr = ChannelAttribute.new 'foo', :enum
      @attr.options.should_not be_nil
    end

    it "should have a scope" do
      @attr = ChannelAttribute.new 'foo', :string
      @attr.should respond_to(:scope)
      @attr.should respond_to(:scope=)
    end

    it "should compute its scoped name" do
      @foo = ChannelAttribute.new 'foo', :string
      @bar = ChannelAttribute.new 'bar', :string
      
      @bar.scoped_name.should eq('bar')
      @bar.scoped_name('bling').should eq('bling[bar]')

      @bar.scope = @foo
      @bar.scoped_name.should eq('foo[bar]')
      @bar.scoped_name('bling').should eq('bling[foo][bar]')
    end
  end
end
