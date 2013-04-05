require 'spec_helper'

module Pigeon
  module Renderer
    describe "ChannelRenderer" do
      before(:each) do
        @channel = Channel.new foo: '42'
        @renderer = ChannelRenderer.new @channel
      end

      it "should handle @f commands" do
        @renderer.render(['@f', 'foo']).should have_tag('input', with: {
          name: 'foo', value: '42'
        })
      end

      it "should handle @l commands" do
        @renderer.render(['@l', 'foo']).should have_tag('label', with: {
          :for => 'foo' }, text: 'Foo')
      end

      it "should handle @a commands" do
        @renderer.render(['@a', 'foo']).should have_tag('div') do
          with_tag 'label', with: { :for => 'foo' }
          with_tag 'input', with: { :name => 'foo', :value => '42' }
        end
      end
    end
  end
end

