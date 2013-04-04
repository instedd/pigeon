require 'spec_helper'

module Pigeon
  describe LayoutHelper do
    describe "pigeon_render_layout"

    describe "pigeon_field_name" do
      it "should nest the field name if given a scope" do
        helper.pigeon_field_name('foo').should eq('foo')
        helper.pigeon_field_name('foo', 'bar').should eq('bar[foo]')
        helper.pigeon_field_name('foo', 'bar[baz]').should eq('bar[baz][foo]')
      end
    end

    describe "pigeon_render_attribute_field" do
      it "should render string attributes" do
        @attr = ChannelAttribute.new 'foo', :string
        helper.pigeon_render_attribute_field(@attr).
          should match(/<label for="foo".*<input.*name="foo".*type="text"/)
      end

      it "should render password attributes" do
        @attr = ChannelAttribute.new 'foo', :password
        helper.pigeon_render_attribute_field(@attr).
          should match(/<label for="foo".*<input.*name="foo".*type="password"/)
      end

      it "should render integer attributes" do
        @attr = ChannelAttribute.new 'foo', :integer
        helper.pigeon_render_attribute_field(@attr).
          should match(/<label for="foo".*<input.*name="foo".*type="number"/)
      end

      it "should render enum attributes" do
        @attr = ChannelAttribute.new 'foo', :enum
        helper.pigeon_render_attribute_field(@attr).
          should match(/<label for="foo".*<select.*name="foo"/)
      end

      it "should render timezone attributes" do
        @attr = ChannelAttribute.new 'foo', :timezone
        helper.pigeon_render_attribute_field(@attr).
          should match(/<label for="foo".*<select.*name="foo"/)
      end

      it "should render boolean attributes" do
        @attr = ChannelAttribute.new 'foo', :boolean
        helper.pigeon_render_attribute_field(@attr).
          should match(/<input.*name="foo".*type="checkbox".*<label for="foo"/)
      end
    end
  end
end

