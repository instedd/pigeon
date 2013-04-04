require 'spec_helper'

module Pigeon
  describe ChannelHelper do
    describe "pigeon_render_attribute_field_only" do
      it "should render string attributes" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute_field_only(@attr).
          should match(/<input.*name="foo".*type="text"/)
      end

      it "should render password attributes" do
        @attr = ChannelAttribute.new 'foo', :password
        helper.pigeon_render_attribute_field_only(@attr).
          should match(/<input.*name="foo".*type="password"/)
      end

      it "should render integer attributes" do
        @attr = ChannelAttribute.new 'foo', :integer
        helper.pigeon_render_attribute_field_only(@attr).
          should match(/<input.*name="foo".*type="number"/)
      end

      it "should render enum attributes" do
        @attr = ChannelAttribute.new 'foo', :enum
        helper.pigeon_render_attribute_field_only(@attr).
          should match(/<select.*name="foo"/)
      end

      it "should render timezone attributes" do
        @attr = ChannelAttribute.new 'foo', :timezone
        helper.pigeon_render_attribute_field_only(@attr).
          should match(/<select.*name="foo"/)
      end

      it "should render boolean attributes" do
        @attr = ChannelAttribute.new 'foo', :boolean
        helper.pigeon_render_attribute_field_only(@attr).
          should match(/<input.*name="foo".*type="checkbox"/)
      end
    end
    
    pending "pigeon_render_attribute_label"
    pending "pigeon_render_attribute"

    pending "pigeon_render_channel_layout"
  end
end

