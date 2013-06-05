module Pigeon
  module Utils

    def to_query(hash)
      hash.map do |key, value|
        "#{key.to_s}=#{CGI.escape(value.to_s)}"
      end.join('&')
    end

    def handle_channel_error(error)
      if error.is_a? RestClient::BadRequest
        response = JSON.parse error.response.body
        raise self.class.error_class.new response['summary'], Hash[response['properties'].map {|e| [e.keys[0], e.values[0]]}]
      else
        raise self.class.error_class.new error.message
      end
    end

    def with_indifferent_access(hash)
      if hash.respond_to? :with_indifferent_access
        hash.with_indifferent_access
      else
        hash
      end
    end

    def get(path)
      resource = RestClient::Resource.new @url, @options
      resource = resource[path].get
      yield resource, nil
    rescue => ex
      yield nil, ex
    end

    def get_json(path)
      get(path) do |response, error|
        raise self.error_class.new error.message if error

        elem = JSON.parse response.body
        elem.map! { |x| with_indifferent_access x } if elem.is_a? Array
        elem
      end
    end

    def post(path, data)
      resource = RestClient::Resource.new @url, @options
      resource = resource[path].post(data)
      yield resource, nil
    rescue => ex
      yield nil, ex
    end

    def put(path, data)
      resource = RestClient::Resource.new @url, @options
      resource = resource[path].put(data)
      yield resource, nil
    rescue => ex
      yield nil, ex
    end

    def delete(path)
      resource = RestClient::Resource.new @url, @options
      resource = resource[path].delete
      yield resource, nil
    rescue => ex
      yield nil, ex
    end

  end
end
