require 'rails_helper'

RSpec.describe PopuliService do
  describe 'api calls' do
    before(:each) do
      @populi = PopuliService.new
      @personId = "12"
      stub_request(:get, "https://turing-validation.populi.co/api2/academicterms/current").
         with(
           headers: {
       	  'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
           }).
         to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term.json')) 

         stub_request(:get, "https://turing-validation.populi.co/api2/people/#{@personId}").
         with(
           headers: {
       	  'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
           }).
         to_return(status: 200, body: File.read('spec/fixtures/populi/get_person.json')) 
    end

    it 'can get current academic term' do
      response = @populi.get_current_academic_term
      expect(response).to be_a(Hash)
      expect(response).to have_key(:object)
      expect(response).to have_key(:id)
      expect(response).to have_key(:name)
      expect(response).to have_key(:display_name)
      expect(response).to have_key(:start_date)
      expect(response).to have_key(:end_date)
      expect(response).to have_key(:type)
      expect(response).to have_key(:academic_year_id)
      expect(response).to have_key(:start_year)
      expect(response).to have_key(:end_year)
      expect(response).to have_key(:non_standard)
    end

    it 'can get person by id' do
      response = @populi.get_person(@personId)
      expect(response).to be_a(Hash)
      expect(response).to have_key(:object)
      expect(response).to have_key(:id)
      expect(response).to have_key(:first_name)
      expect(response).to have_key(:last_name)
      expect(response).to have_key(:middle_name)
      expect(response).to have_key(:addresses)
      expect(response).to have_key(:tags)
      expect(response).to have_key(:added_at)
      expect(response).to have_key(:is_user)
      expect(response).to have_key(:updated_at)
      expect(response).to have_key(:private_profile)
    end
  end
end
