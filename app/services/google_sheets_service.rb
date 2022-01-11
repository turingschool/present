class GoogleSheetsService

  def self.get_headers(google_sheet, user)
    url = sheet_endpoint(google_sheet) + '!1:1'
    response = conn(user).get(url) do |req|
      req.params = {majorDimension: 'ROWS'}
    end
    JSON.parse(response.body, symbolize_names: true)
  end

  def self.update_column(google_sheet, column, values, user)
    range = column_range(column, values)
    url = sheet_endpoint(google_sheet) + '!' + range
    response = conn(user).put(url) do |req|
      req.body = {
        range: range,
        majorDimension: 'COLUMNS',
        values: [values]
      }.to_json

      req.params = {'valueInputOption' => 'RAW'}
    end
    JSON.parse(response.body, symbolize_names: true)
  end

  private
  def self.sheet_endpoint(google_sheet)
    spreadsheet_id = google_sheet.google_spreadsheet.google_id
    sheet_name = google_sheet.name
    "#{spreadsheet_id}/values/#{sheet_name}"
  end

  def self.column_range(column, values)
    start_cell = "#{column}2"
    end_cell = "#{column}#{values.length + 1}"
    "#{start_cell}:#{end_cell}"
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
