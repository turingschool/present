class GoogleSheetsService

  def self.get_sheet_matrix(turing_module, user)
    response = conn(user).get(sheet_endpoint(turing_module)) do |req|
      req.params = {majorDimension: 'COLUMNS'}
    end
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.update_sheet(turing_module, user, sheet_matrix)
    response = conn(user).put(sheet_endpoint(turing_module)) do |req|
      req.body = {
        range: turing_module.google_sheet_name,
        majorDimension: 'COLUMNS',
        values: sheet_matrix
      }.to_json

      req.params = {'valueInputOption' => 'RAW'}
    end
    JSON.parse(response.body, symbolize_names: true)
  end

  private
  def self.sheet_endpoint(turing_module)
    "#{turing_module.google_spreadsheet_id}/values/#{turing_module.google_sheet_name}"
  end

  def self.conn(user)
    Faraday.new(
      url: 'https://sheets.googleapis.com/v4/spreadsheets',
      headers: {
        'Authorization' => "Bearer #{user.google_oauth_token}",
        'content-type' => 'application/json'
      }
    )
  end
end
