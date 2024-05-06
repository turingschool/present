require 'rails_helper'

RSpec.describe AttendanceShowFacade do
  before :each do
    @turing_module = create(:setup_module)
    @attendance = create(:attendance, turing_module: @turing_module)
    @facade = AttendanceShowFacade.new(@attendance)
  end
  
  describe '#turing_module_id'do
    it 'returns the turing module id' do
      expect(@facade.turing_module_id).to eq(@turing_module.id)
    end
  end

  describe '#unasigned_zoom_aliases' do
    it 'returns an array of unclaimed zoom aliases' do
      create_list(:zoom_alias, 10, turing_module: @attendance.turing_module, zoom_meeting_id: @attendance.meeting_id)
      
      # This should not be included in the list of unclaimed aliases from a single zoom meeting
      attendance1 = create(:attendance, turing_module: @turing_module)
      create_list(:zoom_alias, 5, turing_module: attendance1.turing_module, zoom_meeting_id: attendance1.meeting_id)

      expect(@facade.unassigned_zoom_aliases.count).to eq(10)
      expect(@facade.unassigned_zoom_aliases).to be_an(Array)
      expect(@facade.unassigned_zoom_aliases).to be_all(String)
    end
  end
end