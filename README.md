# Pigeon

This gem handles creating, updating and destroying Nuntium and Verboice
channels in your Rails application.

## Installation

Add this line to your application's Gemfile:

    gem 'instedd-pigeon', :require => 'pigeon'

And then execute:

    $ bundle

## Usage

Create an initializer to configure Pigeon:

    Pigeon.setup do |config|
        config.application_name = 'My application'

        config.nuntium_host = 'http://nuntium.instedd.org'
        config.nuntium_account = 'nuntium_account'
        config.nuntium_app = 'nuntium_application'
        config.nuntium_app_password = 'password'

        config.verboice_host = 'http://verboice.instedd.org'
        config.verboice_account = 'account@example.com'
        config.verboice_password = 'password'
        config.verboice_default_call_flow = 'Default Call Flow'

        # If you want to support Nuntium Twitter channels, get your Twitter
        # consumer keys from https://dev.twitter.com/apps
        config.twitter_consumer_key = 'CONSUMER_KEY'
        config.twitter_consumer_secret = 'CONSUMER_SECRET'
    end

Add Pigeon assets to your application, for example by adding to
`app/assets/javascripts/application.js` the line

    //= require pigeon

and to `app/assets/stylesheets/application.css`

    /*
    *= require pigeon
    */

If you need to support Nuntium Twitter channels, mount the Pigeon engine by
adding to your `routes.rb`

    mount Pigeon::Engine => '/pigeon'

It is **strongly advised** to filter the engine's request through
authentication. If your application uses Devise, you can easily do it by
mounting the engine with `authenticate`:

    authenticate :user do
        mount Pigeon::Engine => '/pigeon'
    end

Once properly configured, the gem provides a couple of classes
`Pigeon::NuntiumChannel` and `Pigeon::VerboiceChannel` to manipulate channels
which act as ActiveModels and provide a similar API to
[ActiveResource](https://github.com/rails/activeresource).

Pigeon channels should have a `kind` linking them to schemas which provide
information about the specific attributes required to configure each channel
type. The class methods `schemas` and `find_schema` provide access to all known
schemas.

Sample interaction session:

    > c = Pigeon::NuntiumChannel.new name: 'foo', kind: 'pop3'
    => #<Pigeon::NuntiumChannel:0xa45938c>
    > c.schema.kind
    => "pop3"
    > c.attributes
    => {"protocol"=>"mailto", "priority"=>100, "enabled"=>true, "direction"=>"bidirectional", "configuration"=>{}, "name"=>"foo", "kind"=>"pop3"}
    > c.schema.user_attributes
    => ["configuration[host]", "configuration[port]", "configuration[user]", "configuration[password]", "configuration[use_ssl]", "configuration[remove_quoted_text_or_text_after_first_empty_line]"]
    > c.configuration[:host] = 'example.com'
    => "example.com"
    > c.assign_attributes('configuration[user]' => 'foo', 'configuration[password]' => 'bar')
    => {"configuration[user]"=>"foo", "configuration[password]"=>"bar"}
    > c.save
    => false
    > c.errors.full_messages
    => ["port is not a number"]
    > c.write_attribute('configuration[port]', 110)
    => 110
    > c.new_record?
    => true
    > c.save
    => true
    > Pigeon::NuntiumChannel.list
    => ["foo"]
    > c = Pigeon::NuntiumChannel.find('foo')
    => #<Pigeon::NuntiumChannel:0xb027708>
    > c.kind
    => "pop3"
    > c.new_record?
    => false
    > c.destroy
    => true
    > c.destroyed?
    => true

The gem also provides helpers to aid in the rendering of the channel's
configuration form. The most important ones are
`pigeon_nuntium_channel_kinds_for_select` and
`pigeon_verboice_channel_kinds_for_select` to use as options generators for the
`select_tag` Rails helper, and `pigeon_render_channel_layout` which will render
the fields required for a user to configure the given channel.

For example, in the view:

    <%= form_tag('/channels') do %>
        <%= hidden_field_tag :name, @channel.name %>
        <%= pigeon_render_channel_layout @channel %>
    <%= end %>

Then in the controller:

    def update
        @channel = Pigeon::NuntiumChannel.find(params[:name])
        @channel.assign_attributes(params[:channel])
        @channel.save!
        redirect_to channels_path
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
