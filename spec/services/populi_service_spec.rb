require 'rails_helper'
require './spec/fixtures/populi/stub_requests.rb'

RSpec.describe PopuliService do
  describe 'api calls' do
    before(:each) do
      @populi = PopuliService.new
      @personId = "24490130"
      @course_offering = "10547831"
      stub_call_requests_for_persons
      stub_call_requests_for_course_offerings
      
      stub_request(:get, "https://turing-validation.populi.co/api2/academicterms/current").
        with(
          headers: {
        'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
          }).
        to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term.json')) 
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

    describe 'get_students method' do
      it 'get_course_offering_name method gets course_offering name from Populi API call' do
        response = @populi.get_students(@course_offering)
        expect(response).to be_a(Hash)
        expect(response).to have_key(:body)
        expect(response[:body]).to be_a(Array)
        expect(response[:body].first).to have_key(:first_name)
        expect(response[:body].first).to have_key(:last_name)
        expect(response[:body].first).to have_key(:preferred_name)
        expect(response[:body].first).to have_key(:id)
      end
    end

    describe 'get_enrollments method' do
      it 'get_enrollments method gets enrollments from Populi API call' do
        response = @populi.get_enrollments(@course_offering)
        expect(response).to be_a(Hash)
        expect(response).to have_key(:data)
        expect(response[:data]).to be_a(Array)
        expect(response[:data].first).to be_an(Hash)
        expect(response[:data].first).to have_key(:student_id)
      end
    end
  end
end
