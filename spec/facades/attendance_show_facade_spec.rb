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
    it 'returns an array of unclaimed zoom aliases for a specific attendance' do
      create_list(:zoom_alias, 10, turing_module: @attendance.turing_module, zoom_meeting_id: @attendance.meeting_id)
      
      # This should not be included in the list of unclaimed aliases from a single zoom meeting
      attendance1 = create(:attendance, turing_module: @turing_module)
      create_list(:zoom_alias, 5, turing_module: attendance1.turing_module, zoom_meeting_id: attendance1.meeting_id)

      expect(@facade.unassigned_zoom_aliases.count).to eq(10)
      expect(@facade.unassigned_zoom_aliases).to be_an(Array)
      expect(@facade.unassigned_zoom_aliases).to be_all(String)
    end
  end

  describe '#instructor_zoom_aliases' do
    it 'returns an array of students whos names are all Instructor' do
      student_id = create(:student, turing_module: @turing_module, name: "Instructor").id
      create_list(:student_attendance_present, 10, attendance: @attendance)
      create_list(:student_attendance_present, 1, attendance: @attendance, student_id: student_id)
      create_list(:zoom_alias, 2, turing_module: @attendance.turing_module, zoom_meeting_id: @attendance.meeting_id, student_id: student_id) # Instructor_aliases
      create_list(:zoom_alias, 5, turing_module: @attendance.turing_module, zoom_meeting_id: @attendance.meeting_id) # List of student zoom aliases

      expect(@facade.unassigned_zoom_aliases.count).to eq(5)
      expect(@facade.instructor_zoom_aliases.count).to eq(2)
      expect(@facade.instructor_zoom_aliases).to be_all(ZoomAlias)
      
      @facade.instructor_zoom_aliases.each do |zoom_alias|
        expect(zoom_alias.name).to be_a(String)
      end
    end
  end
end