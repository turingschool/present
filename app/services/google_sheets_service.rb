class GoogleSheetsService

  def get_sheet_matrix(turing_module, user)
    endpoint = "#{turing_module.google_spreadsheet_id}/values/#{google_sheet_name}"
    response = conn(user).get(endpoint)
    JSON.parse(response.body)
  end

  private
  def self.conn(user)
    Faraday.new(
      url: 'https://sheets.googleapis.com/v4/spreadsheets',
      headers: {'Authorization' => "Bearer #{user.google_oauth_token}"}
    )
  end
end
