require 'rails_helper'

RSpec.describe ZoomMeeting do
  describe 'relationships' do
    it {should have_many :zoom_aliases}
    it {should have_one :attendance}
    it {should have_one(:turing_module).through(:attendance)}
  end

  describe "instance methods" do
    describe "#unclaimed_aliases" do
      before :each do
        @zoom = create(:zoom_meeting)
        @unclaimed = create_list(:zoom_alias, 2, zoom_meeting: @zoom)
        @claimed = create_list(:alias_for_student, 2, zoom_meeting: @zoom)
      end

      it 'returns a hash of name/id of all aliases with no student' do
        expected = {
          @unclaimed.first.name => @unclaimed.first.id,
          @unclaimed.second.name => @unclaimed.second.id
        }
        expect(@zoom.unclaimed_aliases).to eq(expected)
      end

      it 'is unique by name' do
        name = @unclaimed.first.name
        create(:zoom_alias, zoom_meeting: @zoom, name: name)
        expect(@zoom.unclaimed_aliases.length).to eq(2)
      end
    end
  end
end