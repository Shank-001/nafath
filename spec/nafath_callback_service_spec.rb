require "spec_helper"
require "jwt"

RSpec.describe Nafath::NafathCallbackService do
  let(:jwt_token) { "test.jwt.token" }
  let(:decoded_payload) { { "status" => "COMPLETED", "transId" => "test-trans-id" } }
  let(:public_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:jwk_key) { JWT::JWK.create_from(public_key).export }
  let(:jwk_response) { { "keys" => [jwk_key] } }

  describe ".decode_jwt" do
    context "when decoding is successful" do
      before do
        allow(described_class).to receive(:retrieve_jwk_keys).and_return([jwk_key])
        allow(JWT).to receive(:decode).and_return([decoded_payload])
      end

      it "returns the decoded JWT payload" do
        result = described_class.decode_jwt(jwt_token)
        expect(result).to eq(decoded_payload)
      end
    end

    context "when decoding fails due to invalid token" do
      before do
        allow(described_class).to receive(:retrieve_jwk_keys).and_return([jwk_key])
        allow(JWT).to receive(:decode).and_raise(JWT::DecodeError, "Invalid signature")
      end

      it "returns an error message" do
        result = described_class.decode_jwt(jwt_token)
        expect(result).to eq({ error: "Invalid signature" })
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(described_class).to receive(:retrieve_jwk_keys).and_raise(StandardError, "Unexpected error")
      end

      it "raises an error message" do
        result = described_class.decode_jwt(jwt_token)
        expect(result).to eq({ error: "Unexpected error" })
      end
    end
  end

  describe ".retrieve_jwk_keys" do
    context "when the JWK keys are retrieved successfully" do
      let(:successful_response) do
        instance_double(HTTParty::Response, success?: true, parsed_response: jwk_response)
      end

      before do
        allow(described_class).to receive(:get).and_return(successful_response)
      end

      it "returns the JWK keys" do
        result = described_class.retrieve_jwk_keys
        expect(result).to eq(jwk_response["keys"])
      end
    end

    context "when the JWK retrieval fails" do
      let(:failed_response) do
        instance_double(HTTParty::Response, success?: false, parsed_response: { "error" => "Unauthorized" })
      end

      before do
        allow(described_class).to receive(:get).and_return(failed_response)
      end

      it "raises an error" do
        expect { described_class.retrieve_jwk_keys }.to raise_error("Failed to retrieve JWK keys")
      end
    end
  end
end
