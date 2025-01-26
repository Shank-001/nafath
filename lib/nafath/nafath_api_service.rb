require 'httparty'

module Nafath
  class NafathApiService
    include HTTParty
    base_uri Nafath.configuration.app_url

    headers 'APP-ID' => Nafath.configuration.app_id,
            'APP-KEY' => Nafath.configuration.app_key,
            'Content-Type' => 'application/json'

    def self.send_request(national_id, service, local, request_id)
      logger = Nafath.logger
      logger.info("Nafath-> Send Request parameters:
        national_id: #{national_id},
        service: #{service},
        local: #{local},
        request_id: #{request_id}")
      response = post('/api/v1/mfa/request',
                      body: {
                        nationalId: national_id,
                        service: service
                      }.to_json,
                      query: { local: local, requestId: request_id })

      if response.success?
        data = response.parsed_response
        logger.info("Nafath-> API responded successfully for request_id: #{request_id}")
        { success: true, random: data['random'], trans_id: data['transId'] }
      else
        logger.error("Nafath-> API request failed for request_id: #{request_id}. Response: #{response.parsed_response}")
        { success: false, error: response.parsed_response }
      end
    end

    def self.retrieve_status(national_id, trans_id, random)
      logger = Nafath.logger
      response = post('/api/v1/mfa/request/status',
                      body: { nationalId: national_id, transId: trans_id, random: random }.to_json)
      logger.info("Nafath-> Retrieve Status parameters:
        national_id: #{national_id},
        trans_id: #{trans_id},
        random: #{random}")

      if response.success?
        status = response.parsed_response['status']
        logger.info("Nafath-> Status retrieved for trans_id: #{trans_id}: #{status}")
        { success: true, status: status }
      else
        logger.error("Nafath-> Failed to retrieve status for trans_id: #{trans_id}. Response: #{response.parsed_response}")
        { success: false, error: response.parsed_response }
      end
    end
  end
end
