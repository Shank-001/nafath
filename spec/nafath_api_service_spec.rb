require "spec_helper"

RSpec.describe Nafath::NafathApiService do
  let(:national_id) { "1012345678" }
  let(:service_type) { "Login" }
  let(:local) { "en" }
  let(:request_id) { "test-request-id" }
  let(:trans_id) { "test-trans-id" }
  let(:random) { "test-random" }

  describe ".send_request" do
    context "when the API call is successful" do
      let(:api_response) do
        instance_double(HTTParty::Response, success?: true, parsed_response: { "random" => random, "transId" => trans_id })
      end

      before do
        allow(described_class).to receive(:post).and_return(api_response)
      end

      it "returns the random number and transaction ID" do
        result = described_class.send_request(national_id, service_type, local, request_id)
        expect(result).to eq({ success: true, random: random, trans_id: trans_id })
      end
    end

    context "when the API call fails" do
      let(:error_response) do
        instance_double(HTTParty::Response, success?: false, parsed_response: { "error" => "Invalid request" })
      end

      before do
        allow(described_class).to receive(:post).and_return(error_response)
      end

      it "returns an error response" do
        result = described_class.send_request(national_id, service_type, local, request_id)
        expect(result).to eq({ success: false, error: { "error" => "Invalid request" } })
      end
    end
  end

  describe ".retrieve_status" do
    context "when the status retrieval is successful" do
      let(:status_response) do
        instance_double(HTTParty::Response, success?: true, parsed_response: { "status" => "COMPLETED" })
      end

      before do
        allow(described_class).to receive(:post).and_return(status_response)
      end

      it "returns the status" do
        result = described_class.retrieve_status(national_id, trans_id, random)
        expect(result).to eq({ success: true, status: "COMPLETED" })
      end
    end

    context "when the status retrieval fails" do
      let(:error_response) do
        instance_double(HTTParty::Response, success?: false, parsed_response: { "error" => "Invalid transaction" })
      end

      before do
        allow(described_class).to receive(:post).and_return(error_response)
      end

      it "returns an error response" do
        result = described_class.retrieve_status(national_id, trans_id, random)
        expect(result).to eq({ success: false, error: { "error" => "Invalid transaction" } })
      end
    end
  end
end
