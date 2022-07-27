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

      expect(page).to have_link('Pairs')
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
        expect(page).to have_link(pair.name)
      end
    end

    it 'links to pair show page' do
      pair = create(:pair)
      visit '/pairs'

      click_on(pair.name)
      expect(current_path).to eq(pair_path(pair))
    end

    it 'displays create new pairing column' do
      visit '/pairs'

      expect(page).to have_content('Create New Pairing')
    end

    it 'can create a new pair' do
      visit '/pairs'

      fill_in 'Name', with: 'Some New Pair Group'
      fill_in 'Size', with: 3
      click_on 'Create Pairs'

      expect(current_path).to eq('/pairs')
      expect(page).to have_content('Pairings created!')

      within '.existing-pairs' do
        expect(page).to have_content('Some New Pair Group')
      end
    end

    it 'handles missing fields for new pair' do
      visit '/pairs'

      click_on 'Create Pairs'

      expect(page).to have_content("Name can't be blank and Size can't be blank")
      expect(current_path).to eq('/pairs')
    end
  end
end
