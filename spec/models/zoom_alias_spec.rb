require 'rails_helper'

RSpec.describe ZoomAlias do
  describe 'validations' do
    it {should validate_presence_of :name}
  end

  describe 'relationships' do
    it {should belong_to(:student).optional}
    it {should belong_to(:zoom_meeting).optional}
  end
end
