require 'spec_helper'

module Pigeon
  describe ChannelHelper do
    before(:each) do
      @schema = ChannelSchema.from_hash 'nuntium', test_schema_hash('foobar')
    end

    describe "pigeon_attribute_field" do
      it "should render string attributes" do
        @attr = ChannelAttribute.new 'foo', :string
        expect(helper.pigeon_attribute_field(@attr)).
          to match(/<input(?=.*type="text")(?=.*name="foo")/)
      end

      it "should render password attributes" do
        @attr = ChannelAttribute.new 'foo', :password
        expect(helper.pigeon_attribute_field(@attr)).
          to match(/<input(?=.*type="password")(?=.*name="foo")/)
      end

      it "should render integer attributes" do
        @attr = ChannelAttribute.new 'foo', :integer
        expect(helper.pigeon_attribute_field(@attr)).
          to match(/<input (?=.*type="number")(?=.*name="foo")/)
      end

      it "should render enum attributes" do
        @attr = ChannelAttribute.new 'foo', :enum
        expect(helper.pigeon_attribute_field(@attr)).
          to match(/<select.*name="foo"/)
      end

      it "should render timezone attributes" do
        @attr = ChannelAttribute.new 'foo', :timezone
        expect(helper.pigeon_attribute_field(@attr)).
          to match(/<select.*name="foo"/)
      end

      it "should render boolean attributes" do
        @attr = ChannelAttribute.new 'foo', :boolean
        expect(helper.pigeon_attribute_field(@attr)).
          to match(/<input(?=.*type="checkbox")(?=.*name="foo")/)
      end

      it "should render an attribute with a forced given type" do
        @attr = ChannelAttribute.new 'foo', :boolean
        expect(helper.pigeon_attribute_field(@attr, false, { type: 'hidden' })).
          to have_tag('input', with: { name: 'foo', type: 'hidden'})
      end

      it "should render an attribute with a forced custom type" do
        @attr = ChannelAttribute.new 'foo', :string
        expect(helper.pigeon_attribute_field(@attr, false, { type: 'url' })).
          to have_tag('input', with: { name: 'foo', type: 'url'})
      end

      it "should accept a scope option" do
        @attr = ChannelAttribute.new 'foo', :string
        expect(helper.pigeon_attribute_field(@attr, nil, scope: 'bar')).
          to match(/<input.*name="bar\[foo\]".*"/)
      end

      it "should accept additional HTML options" do
        @attr = ChannelAttribute.new 'foo', :string
        expect(helper.pigeon_attribute_field(@attr, nil, size: '10')).
          to match(/<input.*name="foo".*size="10"/)
      end
    end
    
    describe "pigeon_attribute_label" do
      before(:each) do
        @attr = ChannelAttribute.new 'foo', :string, label: 'Bar'
      end

      it "should render a <label> tag with the attribute's label" do
        expect(helper.pigeon_attribute_label(@attr)).
          to match(/<label.*>#{@attr.label}<\/label>/)
      end

      it "should set the tag's for attribute" do
        expect(helper.pigeon_attribute_label(@attr)).
          to match(/<label[^>]+for="foo"/)
      end

      it "should accept a scope option" do
        expect(helper.pigeon_attribute_label(@attr, scope: 'bar')).
          to match(/<label[^>]+for="bar_foo"/)
      end

      it "should accept additional HTML options" do
        expect(helper.pigeon_attribute_label(@attr, :class => 'bar')).
          to match(/<label[^>]+class="bar"/)
      end
    end

    describe "pigeon_attribute" do
      it "should render label and field enclosed in a div tag" do
        @attr = ChannelAttribute.new 'foo', :string
        expect(helper.pigeon_attribute(@attr)).
          to match(/<div.*<label.*for="foo".*<input.*name="foo"/)
      end

      it "should invert the render order for boolean attributes" do
        @attr = ChannelAttribute.new 'foo', :boolean
        expect(helper.pigeon_attribute(@attr)).
          to match(/<div.*<input.*name="foo".*<label.*for="foo"/)
      end

      it "should accept a scope option" do
        @attr = ChannelAttribute.new 'foo', :string
        expect(helper.pigeon_attribute(@attr, nil, scope: 'bar')).
          to match(/<div.*<label.*for="bar_foo".*<input.*name="bar\[foo\]"/)
      end

      it "should accept a field_with_errors and wrap the field in a DIV" do
        @attr = ChannelAttribute.new 'foo', :string
        expect(helper.pigeon_attribute(@attr, nil, field_with_errors: true)).
          to match(/<div.*<div.*class="field_with_errors".*<input/)
      end

      it "should accept HTML options for the enclosing tag" do
        @attr = ChannelAttribute.new 'foo', :string
        expect(helper.pigeon_attribute(@attr, nil, :class => 'bar')).
          to match(/<div[^>]+class="bar".*<input.*name="foo"/)
      end
    end

    describe "pigeon_channel_attribute" do
      before(:each) do
        @channel = Channel.new schema: @schema, 
          ticket_code: '1234', configuration: { user: 'joe' }
      end

      it "should render schema's attribute with the channel's value" do
        out = helper.pigeon_channel_attribute(@channel, 'ticket_code')
        expect(out).to match(/<label.*for="ticket_code"/)
        expect(out).to match(/<input.*name="ticket_code"/)
        expect(out).to match(/<input.*type="number"/)
        expect(out).to match(/<input.*value="1234"/)
      end

      it "should render a channel's attribute if not present in schema" do
        @channel.write_attribute('other_attr', 'foobar')
        out = helper.pigeon_channel_attribute(@channel, 'other_attr')
        expect(out).to match(/<label.*for="other_attr"/)
        expect(out).to match(/<input.*name="other_attr"/)
        expect(out).to match(/<input.*type="text"/)
        expect(out).to match(/<input.*value="foobar"/)
      end

      it "should accept a scope option" do
        out = helper.pigeon_channel_attribute(@channel, 'configuration[user]', scope: 'channel')
        expect(out).to match(/<label.*for="channel_configuration_user"/)
        expect(out).to match(/<input.*name="channel\[configuration\]\[user\]"/)
      end

      it "should accept additional HTML options" do
        out = helper.pigeon_channel_attribute(@channel, 'ticket_code', :class => 'code')
        expect(out).to match(/<div.*class="code"/)
      end

      it "should accept a schema-less channel" do
        @channel = Channel.new foo: 42
        expect(helper.pigeon_channel_attribute(@channel, 'foo')).
          to match(/<input.*name="foo"/)
      end

      it "should wrap the field in a DIV if it has errors" do
        @channel.errors.add('configuration[user]', "User can't be blank")
        out = helper.pigeon_channel_attribute(@channel, 'configuration[user]')
        expect(out).to match(/<div.*<div.*class="field_with_errors".*<input.*name="configuration\[user\]"/)
      end
    end
  end
end

