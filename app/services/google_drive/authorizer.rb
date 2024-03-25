# frozen_string_literal: true

module GoogleDrive
  class Authorizer
    SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

    def self.authorize
      credentials = Rails.application.credentials.google_drive_service_account
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(credentials.to_json),
        scope: SCOPE
      )
    end
  end
end
