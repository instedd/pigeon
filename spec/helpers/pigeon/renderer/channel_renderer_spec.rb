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
    end
  end
end

