require 'rails_helper'

RSpec.describe ZoomAlias do
  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_uniqueness_of(:name).scoped_to(:turing_module_id)}
  end

  describe 'relationships' do
    it {should belong_to(:student).optional}
    it {should belong_to(:zoom_meeting).optional}
    it {should belong_to :turing_module}
  end
end
