require 'spec_helper'

module Pigeon
  describe Verboice do
    let(:url) { "http://example.com" }
    let(:options) { {:user => "account", :password => "password", :headers => {:content_type => 'application/json'}} }
    let(:api) { Verboice.new url, 'account', 'password', 'default_channel' }
    let(:schedule) { {"name" => "foo", "retries" => "1,2,3", "time_from" => "10:00", "time_to" => "18:30", "project_id" => '2'} }

    it "calls by channel and address" do
      should_receive_http_get "/api/call?#{api.to_query :channel => 'channel', :address => 'foo'}", '{"call_id": 1, "state": "active"}'
      call = api.call 'foo', :channel => 'channel'
      call['call_id'].should eq(1)
      call['state'].should eq('active')
    end

    it "calls by address with default channel" do
      should_receive_http_get "/api/call?#{api.to_query :channel => 'default_channel', :address => 'foo'}", '{"call_id": 1, "state": "active"}'
      call = api.call 'foo'
      call['call_id'].should eq(1)
      call['state'].should eq('active')
    end

    it "calls by address and custom callback address" do
      should_receive_http_get "/api/call?#{api.to_query :channel => 'channel', :address => 'foo', :callback_url => 'http://foo.com'}", '{"call_id": 1, "state": "active"}'
      call = api.call 'foo', :channel => 'channel', :callback_url => 'http://foo.com'
      call['call_id'].should eq(1)
      call['state'].should eq('active')
    end

    it "calls by address and custom flow" do
      should_receive_http_post "/api/call?#{api.to_query :channel => 'channel', :address => 'foo'}", '<Response/>', '{"call_id": 1, "state": "active"}'
      call = api.call 'foo', :channel => 'channel', :flow => '<Response/>'
      call['call_id'].should eq(1)
      call['state'].should eq('active')
    end

    it "calls by using a queue" do
      should_receive_http_get "/api/call?#{api.to_query :channel => 'default_channel', :address => 'foo', :queue => 'queue_name'}", '{"call_id": 1, "state": "active"}'
      api.call 'foo', :queue => "queue_name"
    end

    it "calls using not_before" do
      time = Time.now
      params = api.to_query :channel => 'default_channel', :address => 'foo', :not_before => time.iso8601
      should_receive_http_get "/api/call?#{params}", '{"call_id": 1, "state": "active"}'
      api.call 'foo', :not_before => time
    end

    it "calls with schedule" do
      should_receive_http_get "/api/call?#{api.to_query :channel => 'default_channel', :address => 'foo', :schedule => 'something'}", '{"call_id": 1, "state": "active"}'
      api.call 'foo', :schedule => "something"
    end

    it "queries call state by id" do
      should_receive_http_get "/api/calls/1/state", '{"call_id": 1, "state": "active"}'
      call = api.call_state 1
      call['call_id'].should eq(1)
      call['state'].should eq('active')
    end

    it "gets channel by name" do
      channel = {"name" => "foo", "username" => "bar"}
      channel_json = channel.to_json

      should_receive_http_get '/api/channels/foo.json', channel_json

      result = api.channel 'foo'
      result.should eq(channel)
    end

    it "creates channel" do
      channel = {"name" => "foo", "username" => "bar"}
      channel_json = channel.to_json
      should_receive_http_post '/api/channels.json', channel_json, channel_json

      result = api.create_channel channel
      result.should eq(channel)
    end

    it "updates channel" do
      channel = {"name" => "foo", "username" => "bar"}
      channel_json = channel.to_json
      should_receive_http_put '/api/channels/foo.json', channel_json, channel_json

      result = api.update_channel channel
      result.should eq(channel)
    end

    it "deletes channel", :focus => true do
      should_receive_http_delete '/api/channels/foo'

      api.delete_channel 'foo'
    end

    it "lists call queues" do
      should_receive_http_get '/api/projects/2/schedules.json', '[{"name":"foo"},{"name":"bar"}]'
      schedules = api.schedules 2
      schedules.should have(2).items
      schedules[0]["name"].should eq('foo')
      schedules[1]["name"].should eq('bar')
    end

    it "gets a call queue by name" do
      should_receive_http_get '/api/projects/2/schedules/foo.json', schedule.to_json
      api.schedule(2, schedule["name"]).should eq(schedule)
    end

    it "creates a call queue" do
      should_receive_http_post '/api/projects/2/schedules', schedule.to_json, nil
      api.create_schedule 2, schedule
    end

    it "updates a call queue" do
      should_receive_http_put "/api/projects/2/schedules/schedule_name", schedule.to_json, nil
      api.update_schedule 2, "schedule_name", schedule
    end

    it "deletes a call queue" do
      should_receive_http_delete "/api/projects/2/schedules/foo"
      api.delete_schedule 2, "foo"
    end

    it "lists channels" do
      should_receive_http_get '/api/channels.json', '["foo", "bar", "baz"]'
      list = api.list_channels
      list.should == ['foo', 'bar', 'baz']
    end

    def should_receive_http_get(path, body = nil)
      resource = mock 'resource'
      RestClient::Resource.should_receive(:new).with(url, options).and_return(resource)

      resource2 = mock 'resource2'
      resource.should_receive(:[]).with(path).and_return(resource2)

      resource3 = mock 'resource3'
      resource2.should_receive(:get).and_return(resource3)

      resource3.should_receive(:body).and_return(body) if body
    end

    def should_receive_http_post(path, data, body)
      resource = mock 'resource'
      RestClient::Resource.should_receive(:new).with(url, options).and_return(resource)

      resource2 = mock 'resource2'
      resource.should_receive(:[]).with(path).and_return(resource2)

      resource3 = mock 'resource3'
      resource2.should_receive(:post).with(data).and_return(resource3)

      resource3.stub(:body) { body }
    end

    def should_receive_http_put(path, data, body)
      resource = mock 'resource'
      RestClient::Resource.should_receive(:new).with(url, options).and_return(resource)

      resource2 = mock 'resource2'
      resource.should_receive(:[]).with(path).and_return(resource2)

      resource3 = mock 'resource3'
      resource2.should_receive(:put).with(data).and_return(resource3)

      resource3.stub(:body) { body }
    end

    def should_receive_http_delete(path)
      resource = mock 'resource'
      RestClient::Resource.should_receive(:new).with(url, options).and_return(resource)

      resource2 = mock 'resource2'
      resource.should_receive(:[]).with(path).and_return(resource2)

      resource3 = mock 'resource3'
      resource2.should_receive(:delete)
    end
  end
end

