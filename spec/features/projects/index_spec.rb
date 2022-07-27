require 'rails_helper'

RSpec.describe 'projects index' do
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

      expect(current_path).to eq('/projects')
    end

    it 'displays the module name and inning' do
      visit '/projects'

      expect(page).to have_content("#{@user.turing_module.inning.name}")
    end

    it 'displays existing pairings column' do
      project = create(:project)

      visit '/projects'

      expect(page).to have_content('Existing Pairings')

      within('.existing-pairs') do
        expect(page).to have_link(project.name)
      end
    end

    it 'links to pair show page' do
      project = create(:project)
      visit '/projects'

      click_on(project.name)
      expect(current_path).to eq(project_path(project))
    end

    it 'displays create new pairing column' do
      visit '/projects'

      expect(page).to have_content('Create New Pairing')
    end

    it 'can create a new pair' do
      visit '/projects'

      fill_in 'Name', with: 'Some New Pair Group'
      fill_in 'Size', with: 3
      click_on 'Create Pairs'

      expect(current_path).to eq('/projects')
      expect(page).to have_content('Pairings created!')

      within '.existing-pairs' do
        expect(page).to have_content('Some New Pair Group')
      end
    end

    it 'handles missing fields for new pair' do
      visit '/projects'

      click_on 'Create Pairs'

      expect(page).to have_content("Name can't be blank and Size can't be blank")
      expect(current_path).to eq('/projects')
    end
  end
end
