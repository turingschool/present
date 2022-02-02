require 'rails_helper'

RSpec.describe GoogleSheet do
  it {should validate_presence_of :name}
  it {should validate_presence_of :google_id}
  it {should belong_to :google_spreadsheet}
  it {should belong_to :turing_module}

  describe 'instance methods' do
    describe '#link' do
      it 'fails' do
        spreadsheet = GoogleSpreadsheet.create!(google_id: '1sb75ubr7sTEwB20LdvA940yky9jPdcRq_MvG-zBvSLY')
        turing_module = create(:turing_module)
        sheet = spreadsheet.google_sheets.create!(google_id: '1626710953', name: '2110', turing_module: turing_module)
        expect(sheet.link).to eq('https://docs.google.com/spreadsheets/d/1sb75ubr7sTEwB20LdvA940yky9jPdcRq_MvG-zBvSLY#gid=1626710953')
      end
    end
  end
end
