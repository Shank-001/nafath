# frozen_string_literal: true

require_relative "nafath/version"
require 'nafath/configuration'
require 'nafath/nafath_api_service'
require 'nafath/nafath_callback_service'

module Nafath
  class Error < StandardError; end

  class << self
    # Get the Configurations
    def configuration
      @configuration ||= Configuration.new
    end

    # Holds the configurtion block.
    def configure
      yield(configuration)
    end

    def send_request(national_id, service_type, local, request_id)
      validate_configuration!
      NafathApiService.send_request(national_id, service_type, local, request_id)
    end

    def retrieve_status(national_id, trans_id, random)
      validate_configuration!
      NafathApiService.retrieve_status(national_id, trans_id, random)
    end

    def decode_jwt(jwt_token)
      validate_configuration!
      NafathCallbackService.decode_jwt(jwt_token)
    end

    def validate_configuration!
      raise "APP ID is not configured" if configuration.app_id.nil?
      raise "APP KEY is not configured" if configuration.app_key.nil?
      raise "API URL is not configured" if configuration.app_url.nil?
    end

    def logger
      defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end    
  end      
end
