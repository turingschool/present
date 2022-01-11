require 'rails_helper'

RSpec.describe GoogleSheetsService do

  it 'can get a google sheets headers' do
    user = mock_login
    test_sheet = create(:m4_attendance_sheet)
    test_spreadsheet = test_sheet.google_spreadsheet

    stub_request(:get, "https://sheets.googleapis.com/v4/spreadsheets/#{test_spreadsheet.google_id}/values/#{test_sheet.name}!1:1?majorDimension=ROWS") \
      .to_return(body: File.read('spec/fixtures/google_sheet_values.json'))

    response = GoogleSheetsService.get_headers(test_sheet, user)
    expect(response[:values]).to be_an(Array)
    expect(response[:values].first).to be_an(Array)
  end

  it 'can update a column' do
    user = mock_login
    test_sheet = create(:m4_attendance_sheet)
    test_spreadsheet = test_sheet.google_spreadsheet
    column = 'AI'
    stub = stub_request(:put, "https://sheets.googleapis.com/v4/spreadsheets/#{test_spreadsheet.google_id}/values/#{test_sheet.name}!AI2:AI43?valueInputOption=RAW") \
      .to_return(body: '{}')

    response = GoogleSheetsService.update_column(test_sheet, column, attendance_values, user)
    expect(stub).to have_been_requested
  end

  let(:attendance_values){
    [
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
      'present',
      'tardy',
      'absent',
    ]
  }
end
