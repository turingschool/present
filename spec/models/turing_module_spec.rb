require 'rails_helper'

RSpec.describe TuringModule, type: :model do
  it { should validate_presence_of :google_spreadsheet_id }
  it { should validate_presence_of :program }
  it { should validate_numericality_of(:module_number).is_greater_than_or_equal_to(1) }
  it { should validate_numericality_of(:module_number).is_less_than_or_equal_to(4) }
  it { should validate_numericality_of(:module_number).only_integer }
  it { should define_enum_for(:program).with_values(([:FE, :BE])) }
  it { should validate_inclusion_of(:calendar_integration).in_array([true, false]) }
  it { should belong_to :inning }
  it { should have_many :attendances }
  xit {should validate_presence_of :google_sheet_name} # Do we need this?


end
