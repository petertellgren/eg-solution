require 'faraday'
require 'json'
require_relative 'eagle/api.rb'

module Eagle

  class Client

    attr_accessor :session, :client_id, :client_key

    # Initializes a new Eagle Api client
    #
    # @param options [Hash]
    # @return [Eagle::Client]
    def initialize(options = {})
      options.each do |key, value|
        send(:"#{key}=", value)
      end

      yield(self) if block_given?

      validate_credentials!

      @session = Faraday.new(:url => 'https://staging.eagle-core.com/api/v1/')
      @auth_params = "?client_id=#{@client_id}&client_key=#{@client_key}"
    end

    def credentials
      {
        :client_id  => client_id,
        :client_key => client_key,
      }
    end

    def call(method, path, params={})
      case method
      when :get
        response = @session.get(path + @auth_params)
      when :post
        response = @session.post do |req|
          req.url path + @auth_params
          req.headers['Content-Type'] = 'application/json'
          req.body = params.to_json
        end
      end

      return JSON.parse(response.body)
    end

    def investigations
      Investigations.new self
    end
    def studies
      Studies.new self
    end

    private

      def validate_credentials!
        credentials.each do |credential, value|
          fail(Eagle::Error::ConfigurationError.new, "You must provide a Eagle #{credential}") if value.empty? || !value.is_a?(String)
        end
      end

  end

end