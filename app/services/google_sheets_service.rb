class GoogleSheetsService

  def self.get_sheet_matrix(turing_module, user)
    endpoint = "#{turing_module.google_spreadsheet_id}/values/#{turing_module.google_sheet_name}"
    response = conn(user).get(endpoint) do |req|
      req.params = {majorDimension: 'COLUMNS'}
    end
    JSON.parse(response.body, symbolize_names: true)
  end

  private
  def self.conn(user)
    Faraday.new(
      url: 'https://sheets.googleapis.com/v4/spreadsheets',
      headers: {'Authorization' => "Bearer #{user.google_oauth_token}"}
    )
  end
end
