require 'rails_helper'

RSpec.describe PopuliService do
  describe 'api calls' do
    before(:each) do
      @populi = PopuliService.new
      @personId = "24490130"
      @course_offering = "10547831"
      @term_id = "295946"
    end

    describe '#person', :vcr do
      it 'can get person by id' do
        response = @populi.person(@personId)
        
        expect(response).to be_a(Hash)
        expect(response).to have_key(:object)
        expect(response).to have_key(:id)
        expect(response).to have_key(:first_name)
        expect(response).to have_key(:last_name)
        expect(response).to have_key(:middle_name)
        expect(response).to have_key(:preferred_name)
        expect(response).to have_key(:added_at)
      end
    end

    describe '#current_academic_term', :vcr do
      it 'can get current academic term' do
        response = @populi.current_academic_term
        
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

    describe '#enrollments method', :vcr do
      it 'enrollments method gets enrollments from Populi API call' do
        response = @populi.enrollments(@course_offering)
        
        expect(response).to be_a(Hash)
        expect(response).to have_key(:data)
        expect(response[:data]).to be_a(Array)
        expect(response[:data].first).to be_an(Hash)
        expect(response[:data].first).to have_key(:student_id)
      end
    end

    describe '#terms method', :vcr do
      it 'terms method gets terms from Populi API call' do
        response = @populi.terms
        
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

    describe '#courseofferings_by_term', :vcr do
      it 'courseofferings_by_term method gets courseofferings by term from Populi API call' do
        
        response = @populi.courseofferings_by_term(@term_id)
        
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

    describe '#update_student_attendance', :vcr do
      context 'update successful' do
        it 'updates student attendance status' do
          current_academic_term = @populi.current_academic_term
          updated_course_offering = @populi.courseofferings_by_term(current_academic_term[:id])[:data].first[:id]
          course_meeting_id = @populi.course_meetings(updated_course_offering)[:data].first[:id]
          enrollment_id = @populi.enrollments(updated_course_offering)[:data].first[:id]
          status = "present"

          response = @populi.update_student_attendance(updated_course_offering, enrollment_id, course_meeting_id, status)

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
          expect(response[:message]).to eq("Could not find a courseoffering object with id 105478")
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
          current_academic_term = @populi.current_academic_term
          updated_course_offering = @populi.courseofferings_by_term(current_academic_term[:id])[:data].first[:id]
          enrollment_id = @populi.enrollments(updated_course_offering)[:data].first[:id]
          status = "present"
          course_meeting_id = "531" # always a four digit code in the API

          response = @populi.update_student_attendance(updated_course_offering, enrollment_id, course_meeting_id, status)
          
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

    describe '#create_student_attendance', :vcr do
      context 'meeting not yet created in populi prior to transfering attendance to populi' do
        it 'creates and updates student_attendances status in populi to excused using start_time' do
          # This test is created to be dynamic and will pass if run on weekdays when classes are scheduled. 
          # It will fail on weekends and during intermissions"
          
          freeze_time
          today = Date.today
          start_time = Time.new(today.year, today.month, today.day, 13, 00, 0)
          current_academic_term = @populi.current_academic_term
          updated_course_offering = @populi.courseofferings_by_term(current_academic_term[:id])[:data].first[:id]
          enrollment_id = @populi.enrollments(updated_course_offering)[:data].first[:id]
          
          response = @populi.create_student_attendance(updated_course_offering, enrollment_id, start_time)
          
          expect(response).to be_a(Hash)
          expect(response).to have_key(:object)
          expect(response[:object]).to eq("course_attendance")
          expect(response).to have_key(:id)
          expect(response).to have_key(:status)
          expect(response[:status]).to eq("excused")
          expect(response).to have_key(:course_meeting_id)
          expect(response).to have_key(:student_id)
        end
      end
    end

    describe 'course_meetings', :vcr do
      it 'provides course meetings based on courseoffering id' do
        response = @populi.course_meetings(@course_offering)

        expect(response).to be_a(Hash)
        expect(response).to have_key(:object)
        expect(response[:object]).to eq("list")
        expect(response).to have_key(:count)
        expect(response).to have_key(:data)

        response[:data].each do |meeting|
          expect(meeting).to be_an(Hash)
          expect(meeting).to have_key(:object)
          expect(meeting).to have_key(:id)
          expect(meeting).to have_key(:course_offering_id)
          expect(meeting).to have_key(:start_at)
          expect(meeting).to have_key(:end_at)
          expect(meeting).to have_key(:room_id)
          expect(meeting).to have_key(:status)
          expect(meeting).to have_key(:summary)
          expect(meeting).to have_key(:counts_toward_attendance_hours)
          expect(meeting).to have_key(:counts_toward_clinical_hours)
        end
      end

      it 'provides an empty array of meetings if no course meetings are found' do
        course_offering = "10548113"
        response = @populi.course_meetings(course_offering)

        expect(response).to be_a(Hash)
        expect(response).to have_key(:object)
        expect(response[:object]).to eq("list")
        expect(response).to have_key(:count)
        expect(response[:count]).to eq(0)
        expect(response).to have_key(:data)
        expect(response[:data]).to eq([])
      end
    end
  end
end
