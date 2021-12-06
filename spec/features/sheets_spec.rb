require 'rails_helper'

describe 'Sheets API Flow' do
  before :each do
    visit root_path

    click_link "Sign In With Google"
    @user = User.last
    @inning = Inning.create!(name: "2107")
    @turing_module = @inning.turing_modules.create!(name: 'Combined Mod 4', google_spreadsheet_id: '1v3C4DXVmmvV1r7vEuo0Xo58AwAJ-SligrplOiLUjWnw', google_sheet_name: "2103")
    @attendance = @turing_module.attendances.create!(zoom_meeting_id: "95544205456")
  end

  it 'can query the Sheets API for spreadsheet values' do
    sheet_matrix = GoogleSheetsService.get_sheet_matrix(@attendance, @user)
    expected_matrix = File.read('fixtures/sheet_matrix')
    expect(sheet_matrix).to eq(expected_matrix)
  end

  xit 'can get a meeting id and return the zoom names stored in the sheet' do


    SheetsFacade.get
  end
    # input is a meeting id, output is array of zoom names


    # input is the array of hashes from zoom api as well as the meeting start time, and output is the updated matrix
end
