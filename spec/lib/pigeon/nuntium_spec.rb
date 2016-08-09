require 'spec_helper'

module Pigeon
  describe Nuntium do
    let(:url) { "http://example.com" }
    let(:options) { {:user => "account/application", :password => "password", :headers => {:content_type => 'application/json'}} }
    let(:api) { Nuntium.new url, "account", "application", "password" }

    it "gets countries" do
      should_receive_http_get '/api/countries.json', %([{"name": "Argentina", "iso2": "ar"}])

      expect(api.countries).to eq(['name' => 'Argentina', 'iso2' => 'ar'])
    end

    it "gets country" do
      should_receive_http_get '/api/countries/ar.json', %({"name": "Argentina", "iso2": "ar"})

      expect(api.country('ar')).to eq({'name' => 'Argentina', 'iso2' => 'ar'})
    end

    it "gets carriers" do
      should_receive_http_get '/api/carriers.json', %([{"name": "Argentina", "iso2": "ar"}])

      expect(api.carriers).to eq(['name' => 'Argentina', 'iso2' => 'ar'])
    end

    it "gets carriers for a country" do
      should_receive_http_get '/api/carriers.json?country_id=ar', %([{"name": "Argentina", "iso2": "ar"}])

      expect(api.carriers('ar')).to eq(['name' => 'Argentina', 'iso2' => 'ar'])
    end

    it "gets carrier" do
      should_receive_http_get '/api/carriers/ar.json', %({"name": "Argentina", "iso2": "ar"})

      expect(api.carrier('ar')).to eq({'name' => 'Argentina', 'iso2' => 'ar'})
    end

    it "gets channels" do
      should_receive_http_get '/api/channels.json', %([{"name": "Argentina", "configuration": [{"name": "foo", "value": "bar"}]}])

      expect(api.channels).to eq([{'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}}])
    end

    it "gets channel" do
      should_receive_http_get '/api/channels/Argentina.json', %({"name": "Argentina", "configuration": [{"name": "foo", "value": "bar"}]})

      expect(api.channel('Argentina')).to eq({'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}})
    end

    it "creates channel" do
      channel_json = %({"name":"Argentina","configuration":[{"name":"foo","value":"bar"}]})
      should_receive_http_post '/api/channels.json', channel_json, channel_json

      channel = {'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}}

      expect(api.create_channel(channel)).to eq(channel)
    end

    it "updates channel", :focus => true do
      channel_json = %({"name":"Argentina","configuration":[{"name":"foo","value":"bar"}]})
      should_receive_http_put '/api/channels/Argentina.json', channel_json, channel_json

      channel = {'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}}

      expect(api.update_channel(channel)).to eq(channel)
    end

    it "deletes channel", :focus => true do
      should_receive_http_delete '/api/channels/Argentina'

      api.delete_channel('Argentina')
    end

    it "gets candidate channels for ao", :focus => true do
      should_receive_http_get "/api/candidate/channels.json?from=#{CGI.escape 'sms://1234'}&body=Hello", %([{"name":"Argentina","configuration":[{"value":"bar","name":"foo"}]}])

      channels = api.candidate_channels_for_ao :from => 'sms://1234', :body => 'Hello'
      expect(channels).to eq([{'name' => 'Argentina', 'configuration' => {'foo' => 'bar'}}])
    end

    it "sends single ao" do
      should_receive_http_get_with_headers "/account/application/send_ao?from=#{CGI.escape 'sms://1234'}&body=Hello", :x_nuntium_id => '1', :x_nuntium_guid => '2', :x_nuntium_token => '3'
      response = api.send_ao :from => 'sms://1234', :body => 'Hello'
      expect(response).to eq("id" => '1', "guid" => '2', "token" => '3')
    end

    it "sends many aos" do
      post_body = %([{"from":"sms://1234","body":"Hello"}])
      should_receive_http_post_with_headers "/account/application/send_ao.json", post_body, :x_nuntium_token => '3'
      response = api.send_ao [{:from => 'sms://1234', :body => 'Hello'}]
      expect(response).to eq("token" => '3')
    end

    it "gets ao" do
      should_receive_http_get '/account/application/get_ao.json?token=foo', %([{"name": "Argentina", "iso2": "ar"}])

      expect(api.get_ao('foo')).to eq([{'name' => 'Argentina', 'iso2' => 'ar'}])
    end

    it "gets custom attributes" do
      should_receive_http_get '/api/custom_attributes?address=foo', %([{"name": "Argentina", "iso2": "ar"}])

      expect(api.get_custom_attributes('foo')).to eq([{'name' => 'Argentina', 'iso2' => 'ar'}])
    end

    it "sets custom attributes" do
      should_receive_http_post '/api/custom_attributes?address=foo', %({"application":"bar"}), ''

      api.set_custom_attributes('foo', :application => :bar)
    end

    it "creates twitter friendship" do
      should_receive_http_get '/api/channels/twit/twitter/friendships/create?user=foo&follow=true'

      api.twitter_friendship_create 'twit', 'foo', true
    end

    it "authorizes twitter channel" do
      should_receive_http_get '/api/channels/twit/twitter/authorize?callback=foo', "http://bar"

      url = api.twitter_authorize 'twit', 'foo'
      expect(url).to eq("http://bar")
    end

    it "adds xmpp contact" do
      should_receive_http_get "/api/channels/chan/xmpp/add_contact?jid=#{CGI.escape 'foo@bar.com'}"

      api.xmpp_add_contact 'chan', 'foo@bar.com'
    end

    def should_receive_http_get(path, body = nil)
      resource = double 'resource'
      expect(RestClient::Resource).to receive(:new).with(url, options).and_return(resource)

      resource2 = double 'resource2'
      expect(resource).to receive(:[]).with(path).and_return(resource2)

      resource3 = double 'resource3'
      expect(resource2).to receive(:get).and_return(resource3)

      expect(resource3).to receive(:body).and_return(body) if body
    end

    def should_receive_http_get_with_headers(path, headers)
      resource = double 'resource'
      expect(RestClient::Resource).to receive(:new).with(url, options).and_return(resource)

      resource2 = double 'resource2'
      expect(resource).to receive(:[]).with(path).and_return(resource2)

      resource3 = double 'resource3'
      expect(resource2).to receive(:get).and_return(resource3)

      allow(resource3).to receive(:headers) { headers }
    end

    def should_receive_http_post(path, data, body)
      resource = double 'resource'
      expect(RestClient::Resource).to receive(:new).with(url, options).and_return(resource)

      resource2 = double 'resource2'
      expect(resource).to receive(:[]).with(path).and_return(resource2)

      resource3 = double 'resource3'
      expect(resource2).to receive(:post).with(data).and_return(resource3)

      allow(resource3).to receive(:body) { body }
    end

    def should_receive_http_post_with_headers(path, data, headers)
      resource = double 'resource'
      expect(RestClient::Resource).to receive(:new).with(url, options).and_return(resource)

      resource2 = double 'resource2'
      expect(resource).to receive(:[]).with(path).and_return(resource2)

      resource3 = double 'resource3'
      expect(resource2).to receive(:post).with(data).and_return(resource3)

      allow(resource3).to receive(:headers) { headers }
    end

    def should_receive_http_put(path, data, body)
      resource = double 'resource'
      expect(RestClient::Resource).to receive(:new).with(url, options).and_return(resource)

      resource2 = double 'resource2'
      expect(resource).to receive(:[]).with(path).and_return(resource2)

      resource3 = double 'resource3'
      expect(resource2).to receive(:put).with(data).and_return(resource3)

      expect(resource3).to receive(:body).and_return(body)
    end

    def should_receive_http_delete(path)
      resource = double 'resource'
      expect(RestClient::Resource).to receive(:new).with(url, options).and_return(resource)

      resource2 = double 'resource2'
      expect(resource).to receive(:[]).with(path).and_return(resource2)

      resource3 = double 'resource3'
      expect(resource2).to receive(:delete)
    end
  end
end
