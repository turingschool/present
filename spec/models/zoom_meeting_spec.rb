require 'rails_helper'

RSpec.describe ZoomMeeting do
  describe 'relationships' do
    it {should have_many :zoom_aliases}
    it {should have_one :attendance}
    it {should have_one(:turing_module).through(:attendance)}
  end
end