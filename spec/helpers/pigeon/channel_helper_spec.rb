require 'spec_helper'

module Pigeon
  describe ChannelHelper do
    before(:each) do
      @schema = ChannelSchema.from_hash 'nuntium', test_schema_hash('foobar')
    end

    describe "pigeon_render_attribute_field" do
      it "should render string attributes" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute_field(@attr).
          should match(/<input.*name="foo".*type="text"/)
      end

      it "should render password attributes" do
        @attr = ChannelAttribute.new 'foo', :password
        helper.pigeon_render_attribute_field(@attr).
          should match(/<input.*name="foo".*type="password"/)
      end

      it "should render integer attributes" do
        @attr = ChannelAttribute.new 'foo', :integer
        helper.pigeon_render_attribute_field(@attr).
          should match(/<input.*name="foo".*type="number"/)
      end

      it "should render enum attributes" do
        @attr = ChannelAttribute.new 'foo', :enum
        helper.pigeon_render_attribute_field(@attr).
          should match(/<select.*name="foo"/)
      end

      it "should render timezone attributes" do
        @attr = ChannelAttribute.new 'foo', :timezone
        helper.pigeon_render_attribute_field(@attr).
          should match(/<select.*name="foo"/)
      end

      it "should render boolean attributes" do
        @attr = ChannelAttribute.new 'foo', :boolean
        helper.pigeon_render_attribute_field(@attr).
          should match(/<input.*name="foo".*type="checkbox"/)
      end

      it "should render an attribute with a forced given type" do
        @attr = ChannelAttribute.new 'foo', :boolean
        helper.pigeon_render_attribute_field(@attr, false, { type: 'hidden' }).
          should have_tag('input', with: { name: 'foo', type: 'hidden'})
      end

      it "should render an attribute with a forced custom type" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute_field(@attr, false, { type: 'url' }).
          should have_tag('input', with: { name: 'foo', type: 'url'})
      end

      it "should accept a scope option" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute_field(@attr, nil, scope: 'bar').
          should match(/<input.*name="bar\[foo\]".*"/)
      end

      it "should accept additional HTML options" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute_field(@attr, nil, size: '10').
          should match(/<input.*name="foo".*size="10"/)
      end
    end
    
    describe "pigeon_render_attribute_label" do
      before(:each) do
        @attr = ChannelAttribute.new 'foo', :string, label: 'Bar'
      end

      it "should render a <label> tag with the attribute's label" do
        helper.pigeon_render_attribute_label(@attr).
          should match(/<label.*>#{@attr.label}<\/label>/)
      end

      it "should set the tag's for attribute" do
        helper.pigeon_render_attribute_label(@attr).
          should match(/<label[^>]+for="foo"/)
      end

      it "should accept a scope option" do
        helper.pigeon_render_attribute_label(@attr, scope: 'bar').
          should match(/<label[^>]+for="bar_foo"/)
      end

      it "should accept additional HTML options" do
        helper.pigeon_render_attribute_label(@attr, :class => 'bar').
          should match(/<label[^>]+class="bar"/)
      end
    end

    describe "pigeon_render_attribute" do
      it "should render label and field enclosed in a div tag" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute(@attr).
          should match(/<div.*<label.*for="foo".*<input.*name="foo"/)
      end

      it "should invert the render order for boolean attributes" do
        @attr = ChannelAttribute.new 'foo', :boolean
        helper.pigeon_render_attribute(@attr).
          should match(/<div.*<input.*name="foo".*<label.*for="foo"/)
      end

      it "should accept a scope option" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute(@attr, nil, scope: 'bar').
          should match(/<div.*<label.*for="bar_foo".*<input.*name="bar\[foo\]"/)
      end

      it "should accept a field_with_errors and wrap the field in a DIV" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute(@attr, nil, field_with_errors: true).
          should match(/<div.*<div.*class="field_with_errors".*<input/)
      end

      it "should accept HTML options for the enclosing tag" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute(@attr, nil, :class => 'bar').
          should match(/<div[^>]+class="bar".*<input.*name="foo"/)
      end
    end

    describe "pigeon_render_channel_attribute" do
      before(:each) do
        @channel = Channel.new schema: @schema, 
          ticket_code: '1234', configuration: { user: 'joe' }
      end

      it "should render schema's attribute with the channel's value" do
        out = helper.pigeon_render_channel_attribute(@channel, 'ticket_code')
        out.should match(/<label.*for="ticket_code"/)
        out.should match(/<input.*name="ticket_code".*type="number".*value="1234"/)
      end

      it "should render a channel's attribute if not present in schema" do
        @channel.write_attribute('other_attr', 'foobar')
        out = helper.pigeon_render_channel_attribute(@channel, 'other_attr')
        out.should match(/<label.*for="other_attr"/)
        out.should match(/<input.*name="other_attr".*type="text".*value="foobar"/)
      end

      it "should accept a scope option" do
        out = helper.pigeon_render_channel_attribute(@channel, 'configuration[user]', scope: 'channel')
        out.should match(/<label.*for="channel_configuration_user"/)
        out.should match(/<input.*name="channel\[configuration\]\[user\]"/)
      end

      it "should accept additional HTML options" do
        out = helper.pigeon_render_channel_attribute(@channel, 'ticket_code', :class => 'code')
        out.should match(/<div.*class="code"/)
      end

      it "should accept a schema-less channel" do
        @channel = Channel.new foo: 42
        helper.pigeon_render_channel_attribute(@channel, 'foo').
          should match(/<input.*name="foo"/)
      end

      it "should wrap the field in a DIV if it has errors" do
        @channel.errors.add('configuration[user]', "User can't be blank")
        out = helper.pigeon_render_channel_attribute(@channel, 'configuration[user]')
        out.should match(/<div.*<div.*class="field_with_errors".*<input.*name="configuration\[user\]"/)
      end
    end
  end
end

