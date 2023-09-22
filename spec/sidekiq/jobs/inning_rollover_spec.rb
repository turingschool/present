require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe InningRolloverJob, type: :job do
  before :each do
    Sidekiq::Testing.inline!
    @inning1 = create(:inning, :is_current)
    @inning2 = create(:inning, :not_current_future)
    Sidekiq::Worker.clear_all
  end
  
  describe 'queueing' do
    it 'queues the job' do
      Sidekiq::Testing.fake!
      expect { InningRolloverJob.perform_async(@inning2.id) }.to change(InningRolloverJob.jobs, :size).by(1)
    end
  end

  describe 'executes perform' do
    it 'makes the new inning current and the old inning not current' do
      InningRolloverJob.perform_async(@inning2.id)

      expect(@inning1.reload.current).to eq(false)
      expect(@inning2.reload.current).to eq(true)
    end

    it 'creates turing modules for the new inning' do
      expect(@inning2.turing_modules.count).to eq(0)
      InningRolloverJob.perform_async(@inning2.id)
      
      expect(@inning2.turing_modules.count).to eq(7)

      expect(@inning2.turing_modules.where(program: 'FE').count).to eq(3)
      expect(@inning2.turing_modules.where(program: 'BE').count).to eq(3)
      expect(@inning2.turing_modules.where(program: 'Combined').count).to eq(1)

      expect(@inning2.turing_modules.where(module_number: 1).count).to eq(2)
      expect(@inning2.turing_modules.where(module_number: 2).count).to eq(2)
      expect(@inning2.turing_modules.where(module_number: 3).count).to eq(2)
      expect(@inning2.turing_modules.where(module_number: 4).count).to eq(1)
    end

    it 'resets the modules for all users' do
      @inning1.create_turing_modules
      user1 = create(:user, turing_module: @inning1.turing_modules.first)
      user2 = create(:user, turing_module: @inning1.turing_modules.second)
      user3 = create(:user, turing_module: @inning1.turing_modules.third)

      expect(user1.turing_module_id).to_not eq(nil)
      expect(user2.turing_module_id).to_not eq(nil)
      expect(user3.turing_module_id).to_not eq(nil)

      InningRolloverJob.perform_async(@inning2.id)
      
      expect(user1.reload.turing_module_id).to eq(nil)
      expect(user2.reload.turing_module_id).to eq(nil)
      expect(user3.reload.turing_module_id).to eq(nil)
    end
  end
end