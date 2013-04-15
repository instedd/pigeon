require 'spec_helper'

module Pigeon
  describe TemplateHelper do
    describe "pigeon_render_template" do
      it "should render static templates" do
        helper.pigeon_render_template(["div"]).should eq("<div></div>")
      end

      it "should delegate commands to the given block" do
        out = helper.pigeon_render_template(["@x"]) do |args|
          args.first.should eq("@x")
          "x marks the spot"
        end
        out.should eq("x marks the spot")
      end

      it "should render unhandled commands as an empty string" do
        helper.pigeon_render_template(["@x"]).should eq("")
      end
    end

    describe "pigeon_render_channel_template" do
      before(:each) do
        @schema = ChannelSchema.from_hash 'nuntium', test_schema_hash('foobar')
        @channel = Channel.new schema: @schema
      end

      it "should render the given template with attributes from the channel" do
        helper.pigeon_render_channel_template(@channel, ['@field', 'ticket_code'], nil).
          should have_tag('input', with: { name: 'ticket_code' })
      end

      it "should render the channel's schema template by default" do
        out = helper.pigeon_render_channel_template(@channel, nil, nil)
        out.should have_tag('input', with: { name: 'ticket_code' })
        out.should have_tag('input', with: { name: 'configuration[user]' })
      end

      it "should delegate unknown commands to the given block" do
        helper.pigeon_render_channel_template(@channel, ['@x']) do |args|
          args.first.should eq('@x')
          'XXX'
        end.should eq('XXX')
      end

      it "should by default use the 'channel' scope" do
        helper.pigeon_render_channel_template(@channel, ['@field', 'ticket_code']).  should have_tag('input', with: { name: 'channel[ticket_code]' })
      end

      it "should wrap channel's attributes in the given scope" do
        helper.pigeon_render_channel_template(@channel, ['@field', 'ticket_code'], 'foo').  should have_tag('input', with: { name: 'foo[ticket_code]' })
      end
    end
  end
end

