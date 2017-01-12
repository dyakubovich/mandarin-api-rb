# frozen_string_literal: true
require 'json'
require 'rest-client'
module MandarinApi
  # Wraps request sending
  class Wrapper
    def initialize(merchant_id:, secret:)
      @merchant_id = merchant_id
      @secret = secret
    end

    def request(endpoint, params = {})
      url = URI.join(MandarinApi.config.request_url, endpoint).to_s
      RestClient.post(url, json(params), header) do |response|
        case response.code
        when 200
          JSON.parse response.body
        else
          { 'status' => response.code, 'error' => 'Invalid request' }
        end
      end
    end

    private

    def header
      {
        content_type: :json,
        x_auth: generate_x_auth_header(@merchant_id, @secret)
      }
    end

    def generate_x_auth_header(merchant_id, secret)
      request_id = SecureRandom.uuid
      hash = Digest::SHA256.hexdigest "#{merchant_id}-#{request_id}-#{secret}"
      "#{merchant_id}-#{hash}-#{request_id}"
    end

    def json(params = {})
      JSON.generate(key_transform(params))
    end

    def key_transform(hash)
      new_hash = {}
      hash.keys.each do |key|
        new_hash[camelize(key.to_s)] = if hash[key].class == Hash
                                         key_transform hash[key]
                                       elsif hash[key].class == Array
                                         hash[key].map { |e| key_transform e }
                                       else
                                         hash[key]
                                       end
      end
      new_hash
    end

    def camelize(str)
      str.split('_').map.with_index(0) do |letter, index|
        if index.zero?
          letter
        else
          letter.capitalize
        end
      end.join
    end
  end
end
