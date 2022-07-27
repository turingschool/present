require 'rails_helper'

RSpec.describe 'pairs index' do
  before(:each) do
    @user = mock_login
    @current_inning = create(:inning, name:'2108', current: true)
    @test_module = create(:backend, inning: @current_inning)
    @user.update(turing_module: @test_module)
  end

  context 'button to index' do
    it 'can click button and take us to the index page' do
      visit root_path

      expect(page).to have_button('Pairs')
      click_on('Pairs')

      expect(current_path).to eq('/pairs')
    end

    it 'displays the module name and inning' do
      visit '/pairs'

      expect(page).to have_content("#{@user.turing_module.inning.name}")
    end

    it 'displays existing pairings column' do
      pair = create(:pair)

      visit '/pairs'

      expect(page).to have_content('Existing Pairings')

      within('.existing-pairs') do
        expect(page).to have_content(pair.name)
      end
    end

    it 'displays create new pairing column' do
      visit '/pairs'

      expect(page).to have_content('Create New Pairing')
    end
  end
end
