require 'rails_helper'

RSpec.describe Inning, type: :model do
  describe 'relationships' do 
    it {should have_many :turing_modules}
  end 

  describe 'validations' do
    it {should validate_presence_of :name}
    it 'has current set to false by default upon creation' do 
      inning = Inning.create(name: '2108')
      expect(inning.current).to eq(false)
    end 
  end 

  describe 'instance methods' do 
    it '#update_current_status_for_all_other_innings' do 
      past_innings = create_list(:inning,3)
      current_inning = create(:inning, current: true)
      
      past_innings.first.update_current_status_for_all_other_innings

      Inning.all.reload

      expect(past_innings.first.current).to eq(true)

      expect(Inning.where.not(id: past_innings.first.id).all?{ |inning| !inning.current }).to eq(true)
    end 
  end 

end
