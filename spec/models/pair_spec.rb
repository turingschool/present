require 'rails_helper'

RSpec.describe Pair, type: :model do
  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :size}
  end
end
