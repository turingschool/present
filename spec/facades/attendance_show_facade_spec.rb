require 'rails_helper'

RSpec.describe AttendanceShowFacade do
  describe '#turing_module_id'do
    it 'returns the turing module id' do
      turing_module = create(:setup_module)
      attendance = create(:attendance, turing_module: turing_module)
      facade = AttendanceShowFacade.new(attendance)
      
      expect(facade.turing_module_id).to eq(turing_module.id)
    end
  end
end