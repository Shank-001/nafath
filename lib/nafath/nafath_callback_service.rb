require "httparty"
require "jwt"

module Nafath
  class NafathCallbackService
    include HTTParty
    base_uri ENV["NAFATH_API_URL"]

    headers "APP-ID" => ENV["NAFATH_APP_ID"],
            "APP-KEY" => ENV["NAFATH_APP_KEY"],
            "Content-Type" => "application/json"

    @logger = LogHelper.logger
    @error_logger = LogHelper.error_logger

    def self.decode_jwt(jwt_token)
      jwk_key = retrieve_jwk_keys.first
      public_key = JWT::JWK::RSA.import(jwk_key).public_key

      decoded_token = JWT.decode(jwt_token, public_key, true, { algorithm: "RS256" }).first
      @logger.info("Nafath-> Successfully decoded JWT token: #{decoded_token}")
      decoded_token
    rescue JWT::DecodeError => e
      @error_logger.error("Nafath-> Failed to decode JWT token: #{e.message}")
      { error: e.message }
    rescue StandardError => e
      @error_logger.error("Nafath-> Unexpected error during JWT decoding: #{e.message}")
      { error: e.message }
    end

    def self.retrieve_jwk_keys
      response = get("/api/v1/mfa/jwk")

      if response.success?
        jwk_keys = response.parsed_response["keys"]
        @logger.info("Nafath-> Successfully retrieved JWK keys: #{jwk_keys}")
        jwk_keys
      else
        @error_logger.error("Nafath-> Failed to retrieve JWK keys. Response: #{response.parsed_response}")
        raise "Failed to retrieve JWK keys"
      end
    rescue StandardError => e
      @error_logger.error("Nafath-> Unexpected error during JWK key retrieval: #{e.message}")
      raise e
    end
  end
end
