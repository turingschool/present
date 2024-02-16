require 'rails_helper'
require './spec/fixtures/populi/test_data/stub_requests.rb'

RSpec.describe PopuliService do
  describe 'api calls' do
    before(:each) do
      @populi = PopuliService.new
      @personId = "24490130"
      @course_offering = "10547831"
      @term_id = "295946"
      stub_persons
      stub_get_enrollments
      stub_academic_terms
      stub_current_academic_term
      stub_course_offerings_by_term
      stub_successful_update_student_attendance
      stub_failed_update_student_attendance
    end

    describe '#get_person' do
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

    describe '#get_current_academic_term' do
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
    end  

    describe '#get_enrollments method' do
      it 'get_enrollments method gets enrollments from Populi API call' do
        response = @populi.get_enrollments(@course_offering)
        expect(response).to be_a(Hash)
        expect(response).to have_key(:data)
        expect(response[:data]).to be_a(Array)
        expect(response[:data].first).to be_an(Hash)
        expect(response[:data].first).to have_key(:student_id)
      end
    end

    describe '#get_terms method' do
      it 'get_terms method gets terms from Populi API call' do
        response = @populi.get_terms
        expect(response).to be_a(Hash)
        expect(response).to have_key(:data)
        expect(response[:data]).to be_a(Array)
        expect(response[:data].first).to be_an(Hash)
        expect(response[:data].first).to have_key(:id)
        expect(response[:data].first).to have_key(:name)
        expect(response[:data].first).to have_key(:start_date)
        expect(response[:data].first).to have_key(:end_date)
      end
    end

    describe '#get_courseofferings_by_term' do
      it 'get_courseofferings_by_term method gets courseofferings by term from Populi API call' do
        response = @populi.get_courseofferings_by_term(@term_id)
        expect(response).to be_a(Hash)
        expect(response).to have_key(:data)
        expect(response[:data]).to be_a(Array)
        expect(response[:data].first).to be_an(Hash)
        expect(response[:data].first).to have_key(:catalog_courses)
        catalog_courses = response[:data].first[:catalog_courses]
        expect(catalog_courses).to be_an(Array)
        expect(catalog_courses.first).to have_key(:course_offering_id)
        expect(catalog_courses.first).to have_key(:catalog_course_id)
        expect(catalog_courses.first).to have_key(:abbrv)
        expect(catalog_courses.first).to have_key(:name)
      end
    end

    describe '#update_student_attendance' do
      context 'update successful' do
        it 'updates student attendance status' do
          course_offering_id_1 = "10547884"
          enrollment_id_1 = "76297621"
          status = "present"
          course_meeting_id_1 = "5314"
          response = @populi.update_student_attendance(course_offering_id_1, enrollment_id_1, course_meeting_id_1, status)

          expect(response).to be_a(Hash)
          expect(response).to have_key(:object)
          expect(response[:object]).to eq("course_attendance")
          expect(response).to have_key(:id)
          expect(response).to have_key(:status)
          expect(response[:status]).to eq("present")
          expect(response).to have_key(:course_meeting_id)
          expect(response).to have_key(:student_id)
        end
      end

      context 'update failed' do
        it 'provides error message with wrong course_offering_id' do
          course_offering_id = "105478"
          enrollment_id = "76297621"
          status = "PRESENT"
          course_meeting_id = "5314"
          response = @populi.update_student_attendance(course_offering_id, enrollment_id, course_meeting_id, status)
          expect(response).to be_a(Hash)
          expect(response).to have_key(:object)
          expect(response[:object]).to eq("error")
          expect(response).to have_key(:message)
          expect(response[:message]).to eq("Could not find a courseoffering object with id 1054788")
        end

        it 'provides error message with wrong enrollment_id' do
          course_offering_id = "10547884"
          enrollment_id = "762976"
          status = "PRESENT"
          course_meeting_id = "5314"
          response = @populi.update_student_attendance(course_offering_id, enrollment_id, course_meeting_id, status)
          expect(response).to be_a(Hash)
          expect(response).to have_key(:object)
          expect(response[:object]).to eq("error")
          expect(response).to have_key(:message)
          expect(response[:message]).to eq("Could not find a coursestudent object with id 762976")
        end

        it 'provides error message with wrong course_meeting_id' do
          course_offering_id = "10547884"
          enrollment_id = "76297621"
          status = "PRESENT"
          course_meeting_id = "531"
          response = @populi.update_student_attendance(course_offering_id, enrollment_id, course_meeting_id, status)
          expect(response).to be_a(Hash)
          expect(response).to have_key(:object)
          expect(response[:object]).to eq("error")
          expect(response).to have_key(:message)
          expect(response[:message]).to eq("The specified course_meeting does not exist in this course instance.")
        end

        it 'provides error message for finalized enrollment' do
          course_offering_id = "10547884"
          enrollment_id = "76297620"
          status = "PRESENT"
          course_meeting_id = "5314"
          response = @populi.update_student_attendance(course_offering_id, enrollment_id, course_meeting_id, status)
          expect(response).to be_a(Hash)
          expect(response).to have_key(:object)
          expect(response[:object]).to eq("error")
          expect(response).to have_key(:message)
          expect(response[:message]).to eq("You cannot update attendance for a finalized student.")
        end
      end
    end
  end
end
