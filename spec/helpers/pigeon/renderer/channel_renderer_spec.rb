require 'spec_helper'

module Pigeon
  module Renderer
    describe "ChannelRenderer" do
      before(:each) do
        @channel = Channel.new foo: '42'
        @renderer = ChannelRenderer.new @channel
      end

      it "should handle @field commands" do
        @renderer.render(['@field', 'foo']).should have_tag('input', with: {
          name: 'foo', value: '42'
        })
      end

      it "should handle @label commands" do
        @renderer.render(['@label', 'foo']).should have_tag('label', with: {
          :for => 'foo' }, text: 'Foo')
      end

      it "should handle @attr commands" do
        @renderer.render(['@attr', 'foo']).should have_tag('div') do
          with_tag 'label', with: { :for => 'foo' }
          with_tag 'input', with: { :name => 'foo', :value => '42' }
        end
      end

      it "should handle @hidden commands" do
        @renderer.render(['@hidden', 'foo']).should have_tag('input', with: {
          name: 'foo', type: 'hidden'
        })
      end

      it "should accept options for attribute commands" do
        @renderer.render(['@attr', { "class" => "field" }, 'foo']).should \
            have_tag('div', with: { 'class' => 'field' }) do
          with_tag 'label'
          with_tag 'input'
        end
      end

      context "with a scope" do
        before(:each) do
          @channel = Channel.new foo: '42'
          @renderer = ChannelRenderer.new @channel, 'channel_data'
        end

        it "should add a scope attribute to @layout and @wizard commands" do
          @renderer.render(['@layout']).should have_tag('div', with: {
            "data-scope" => "channel_data"
          })
        end
      end
    end
  end
end

