module V1
  class NafathRequestsController < ApplicationController
    before_action :validate_json_web_token, except: :receive_callback

    COMPLETED = 'COMPLETED'

    def create_mfa_request
      national_id = create_request_params[:national_id]
      service_type = 'DigitalServiceEnrollmentWithoutBio'

      local = params[:local] || 'en'
      request_id = SecureRandom.uuid

      result = Nafath.send_request(national_id, service_type, local, request_id)

      if result[:success]
        store_request_id_and_trans_id(request_id, result[:trans_id])
        render json: { random: result[:random], trans_id: result[:trans_id], request_id: request_id }, status: :ok
      else
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def retrieve_status
      national_id = retrieve_status_params[:national_id]
      trans_id = retrieve_status_params[:trans_id]
      random = retrieve_status_params[:random]

      result = Nafath.retrieve_status(national_id, trans_id, random)
      if result[:success]
        current_user.update(is_kyc_done: true) if result[:status] == COMPLETED
        render json: { status: result[:status] }, status: :ok
      else
        failed_activity_log(current_user)
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
    end

    def receive_callback
      logger = Rails.logger
      logger.info("Nafath Callback Params: #{params}")

      jwt_token = params[:token]
      trans_id = params[:transId]
      request_id = params[:requestId]
      if request_id.blank? || trans_id.blank?
        return render json: { error: 'Missing request_id or trans_id' }, status: :unprocessable_entity
      end

      return render json: { error: 'Missing JWT Token' }, status: :unprocessable_entity if jwt_token.blank?

      logger.info("Nafath request ID and trans ID in Callback: RID:#{request_id} TID:#{trans_id}")
      matching_personal_info = V1::PersonalInformation.find_by(nafath_request_id: request_id,
                                                                         nafath_trans_id: trans_id)
      unless matching_personal_info
        return render json: { error: 'No matching Personal Information record found for the provided request ID and transaction ID.' },
                      status: :not_found
      end

      logger.info("Matching Personal Information and Account ID in Callback: PID:#{matching_personal_info.id} AID:#{matching_personal_info&.account&.id}")
      user_info = Nafath.decode_jwt(jwt_token)

      if user_info['status'] == 'COMPLETED'
        store_personal_information(matching_personal_info, user_info)
        logger.info("User authentication completed for request ID and trans ID: RID:#{request_id} TID:#{trans_id}")
        render json: { message: 'Nafath Authentication Successful' }, status: :ok
      else
        render json: { error: 'Authentication Failed' }, status: :unprocessable_entity
      end
    end

    private

    def create_request_params
      params.require(:data).permit(:national_id)
    end

    def retrieve_status_params
      params.require(:data).permit(:national_id, :trans_id, :random, :request_id)
    end

    def store_request_id_and_trans_id(request_id, trans_id)
      latest_personal_info = current_user.personal_informations.last
      unless latest_personal_info
        raise ActiveRecord::RecordNotFound,
              'Unable to store request ID and transaction ID. No Personal Information record was found for the current user.'
      end

      latest_personal_info.update!(nafath_request_id: request_id, nafath_trans_id: trans_id)
    end

    def store_personal_information(personal_information, user_info)
      attributes = map_user_info_to_personal_info(personal_information, user_info)

      # Keep track of which fields are being updated
      updated_attributes = attributes.select { |_key, value| value.present? }

      personal_information.assign_attributes(updated_attributes)
      personal_information.save(validate: false)
    end

    def map_user_info_to_personal_info(personal_information, user_info)
      {
        mobile_number: personal_information.account.full_phone_number,
        first_name_en: user_info['englishFirstName'],
        father_name_en: user_info['englishSecondName'],
        grandfather_name_en: user_info['englishThirdName'],
        family_name_en: user_info['englishLastName'],
        first_name_ar: user_info['firstName'],
        father_name_ar: user_info['secondName'],
        grandfather_name_ar: user_info['thirdName'],
        family_name_ar: user_info['lastName'],
        national_id_number: user_info['sub'].to_i,
        iqama_id_number: user_info['iqamaNumber'],
        id_issue_date_g: user_info['iqamaIssueDateG'],
        id_issue_date_h: user_info['iqamaIssueDateH'],
        id_expiry_date_g: user_info['iqamaExpiryDateG'],
        id_expiry_date_h: user_info['iqamaExpiryDateH'],
        id_issuance_place_ar: user_info['iqamaIssuePlaceDesc'],
        copy_number: user_info['iqamaVersionNumber'],
        dob_g: user_info['dateOfBirthG'],
        dob_h: user_info['dateOfBirthH'],
        nationality_id: user_info['nationalityCode'].to_i,
        gender: user_info['gender'] == 'M' ? 'Male' : 'Female',
        marital_status_code: user_info.fetch('socialStatusCode', nil)&.to_i,
        marital_status: user_info.fetch('socialStatusDesc', nil)
      }
    end

    def update_flags(personal_information, updated_keys)
      flag_attributes = {}

      # Map the database fields to their respective "_updated" flags
      flag_mapping = {
        mobile_number: :mobile_number_updated,
        first_name_en: :first_name_en_updated,
        father_name_en: :father_name_en_updated,
        grandfather_name_en: :grandfather_name_en_updated,
        family_name_en: :family_name_en_updated,
        first_name_ar: :first_name_ar_updated,
        father_name_ar: :father_name_ar_updated,
        grandfather_name_ar: :grandfather_name_ar_updated,
        family_name_ar: :family_name_ar_updated,
        iqama_id_number: :iqama_id_number_updated,
        id_issue_date_g: :id_issue_date_g_updated,
        id_issue_date_h: :id_issue_date_h_updated,
        id_expiry_date_g: :id_expiry_date_g_updated,
        id_expiry_date_h: :id_expiry_date_h_updated,
        id_issuance_place_ar: :id_issuance_place_ar_updated,
        copy_number: :copy_number_updated,
        dob_g: :dob_g_updated,
        dob_h: :dob_h_updated,
        nationality_id: :nationality_id_updated,
        gender: :gender_updated,
        marital_status_code: :marital_status_code_updated,
        marital_status: :marital_status_updated
      }

      personal_information.assign_attributes(flag_attributes)
      personal_information.save(validate: false)
    end
  end
end
