require 'rails_helper'
require './spec/fixtures/populi/stub_requests.rb'

RSpec.describe PopuliFacade do
  describe 'instance methods' do
    before(:each) do
      turing_module = create(:setup_module)
      @term_id = "295946"
      @populi = PopuliFacade.new(turing_module)
      @course_offering = "10547831"
      stub_persons
      stub_get_enrollments
      stub_course_offerings_by_term
    end

    describe '#get_students' do
      it 'filters through enrollment objects to return students objects' do
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

    describe '#get_term_courses' do
      it 'filters through courseoffering objects to return calatog courses' do
        response = @populi.get_term_courses(@term_id)
        expect(response).to be_a(Array)
        response.each do |course|
          expect(course).to_not be_empty
        end
        expect(response.first).to be_a(Hash)
        expect(response.first).to have_key(:id)
        expect(response.first).to have_key(:name)
        expect(response.first).to have_key(:abbrv)
        expect(response.first).to have_key(:course_offering_id)
        expect(response.first).to have_key(:catalog_course_id)
      end
    end
  end
end