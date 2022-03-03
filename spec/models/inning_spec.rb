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
    it '#make_current_inning' do 
      past_innings = create_list(:inning,3)
      current_inning = create(:inning, current: true)
      
      past_innings.first.make_current_inning

      Inning.all.reload

      expect(past_innings.first.current).to eq(true)

      expect(Inning.where.not(id: past_innings.first.id).all?{ |inning| !inning.current }).to eq(true)
    end 
  end 

  describe 'class methods' do 
    it '.order_by_name' do 
      inning_1 = Inning.create(name: '2201')
      inning_2 = Inning.create(name: '2108')
      inning_3 = Inning.create(name: '2210')

      expect(Inning.order_by_name).to eq([inning_3, inning_1, inning_2])
    end 
  end 

end
