require 'spec_helper'

module Pigeon
  module Renderer
    describe "ChannelRenderer" do
      before(:each) do
        @channel = Channel.new foo: '42'
        @renderer = ChannelRenderer.new @channel
      end

      it "should handle @field commands" do
        expect(@renderer.render(['@field', 'foo'])).to have_tag('input', with: {
          name: 'foo', value: '42'
        })
      end

      it "should handle @label commands" do
        expect(@renderer.render(['@label', 'foo'])).to have_tag('label', with: {
          :for => 'foo' }, text: 'Foo')
      end

      it "should handle @attr commands" do
        expect(@renderer.render(['@attr', 'foo'])).to have_tag('div') do
          with_tag 'label', with: { :for => 'foo' }
          with_tag 'input', with: { :name => 'foo', :value => '42' }
        end
      end

      it "should handle @hidden commands" do
        expect(@renderer.render(['@hidden', 'foo'])).to have_tag('input', with: {
          name: 'foo', type: 'hidden'
        })
      end

      it "should accept options for attribute commands" do
        expect(@renderer.render(['@attr', { "class" => "field" }, 'foo'])).to \
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

        it "should add a scope attribute to @template and @wizard commands" do
          expect(@renderer.render(['@template'])).to have_tag('div', with: {
            "data-scope" => "channel_data"
          })
          expect(@renderer.render(['@wizard'])).to have_tag('div', with: {
            "data-scope" => "channel_data"
          })
        end
      end
    end
  end
end

