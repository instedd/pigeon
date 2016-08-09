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
      expect(call['call_id']).to eq(1)
      expect(call['state']).to eq('active')
    end

    it "calls by address with default channel" do
      should_receive_http_get "/api/call?#{api.to_query :channel => 'default_channel', :address => 'foo'}", '{"call_id": 1, "state": "active"}'
      call = api.call 'foo'
      expect(call['call_id']).to eq(1)
      expect(call['state']).to eq('active')
    end

    it "calls by address and custom callback address" do
      should_receive_http_get "/api/call?#{api.to_query :channel => 'channel', :address => 'foo', :callback_url => 'http://foo.com'}", '{"call_id": 1, "state": "active"}'
      call = api.call 'foo', :channel => 'channel', :callback_url => 'http://foo.com'
      expect(call['call_id']).to eq(1)
      expect(call['state']).to eq('active')
    end

    it "calls by address and custom flow" do
      should_receive_http_post "/api/call?#{api.to_query :channel => 'channel', :address => 'foo'}", '<Response/>', '{"call_id": 1, "state": "active"}'
      call = api.call 'foo', :channel => 'channel', :flow => '<Response/>'
      expect(call['call_id']).to eq(1)
      expect(call['state']).to eq('active')
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
      expect(call['call_id']).to eq(1)
      expect(call['state']).to eq('active')
    end

    it "gets channel by name" do
      channel = {"name" => "foo", "username" => "bar"}
      channel_json = channel.to_json

      should_receive_http_get '/api/channels/foo.json', channel_json

      result = api.channel 'foo'
      expect(result).to eq(channel)
    end

    it "creates channel" do
      channel = {"name" => "foo", "username" => "bar"}
      channel_json = channel.to_json
      should_receive_http_post '/api/channels.json', channel_json, channel_json

      result = api.create_channel channel
      expect(result).to eq(channel)
    end

    it "updates channel" do
      channel = {"name" => "foo", "username" => "bar"}
      channel_json = channel.to_json
      should_receive_http_put '/api/channels/foo.json', channel_json, channel_json

      result = api.update_channel channel
      expect(result).to eq(channel)
    end

    it "deletes channel", :focus => true do
      should_receive_http_delete '/api/channels/foo'

      api.delete_channel 'foo'
    end

    it "lists call queues" do
      should_receive_http_get '/api/projects/2/schedules.json', '[{"name":"foo"},{"name":"bar"}]'
      schedules = api.schedules 2
      expect(schedules.size).to eq(2)
      expect(schedules[0]["name"]).to eq('foo')
      expect(schedules[1]["name"]).to eq('bar')
    end

    it "gets a call queue by name" do
      should_receive_http_get '/api/projects/2/schedules/foo.json', schedule.to_json
      expect(api.schedule(2, schedule["name"])).to eq(schedule)
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
      expect(list).to eq(['foo', 'bar', 'baz'])
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

    def should_receive_http_post(path, data, body)
      resource = double 'resource'
      expect(RestClient::Resource).to receive(:new).with(url, options).and_return(resource)

      resource2 = double 'resource2'
      expect(resource).to receive(:[]).with(path).and_return(resource2)

      resource3 = double 'resource3'
      expect(resource2).to receive(:post).with(data).and_return(resource3)

      allow(resource3).to receive(:body) { body }
    end

    def should_receive_http_put(path, data, body)
      resource = double 'resource'
      expect(RestClient::Resource).to receive(:new).with(url, options).and_return(resource)

      resource2 = double 'resource2'
      expect(resource).to receive(:[]).with(path).and_return(resource2)

      resource3 = double 'resource3'
      expect(resource2).to receive(:put).with(data).and_return(resource3)

      allow(resource3).to receive(:body) { body }
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

