puts "\n== Seeding the database with fake data created by Turing's team RubyHive. Thank you for your patience. ==\n\n"



ZoomAlias.destroy_all
ZoomMeeting.destroy_all
Inning.destroy_all
TuringModule.destroy_all

# Innings
inning = Inning.create!(name: Date.today.strftime("%y%m"), current: true, start_date: Date.today)


# Turing Modules
mod4 = inning.turing_modules.create!(program: 'Combined', module_number: 4)
fe1 = inning.turing_modules.create!(program: 'FE', module_number: 1)
fe2 = inning.turing_modules.create!(program: 'FE', module_number: 2)
fe3 = inning.turing_modules.create!(program: 'FE', module_number: 3)
be1 = inning.turing_modules.create!(program: 'BE', module_number: 1)
be2 = inning.turing_modules.create!(program: 'BE', module_number: 2)
be3 = inning.turing_modules.create!(program: 'BE', module_number: 3)


# Students
10.times do
  Student.create(name: Faker::Name.name, turing_module_id: mod4.id)
end

10.times do
  Student.create(name: Faker::Name.name, turing_module_id: fe1.id)
end

10.times do
  Student.create(name: Faker::Name.name, turing_module_id: fe2.id)
end

10.times do
  Student.create(name: Faker::Name.name, turing_module_id: fe3.id)
end

10.times do
  Student.create(name: Faker::Name.name, turing_module_id: be1.id)
end

10.times do
  Student.create(name: Faker::Name.name, turing_module_id: be2.id)
end

10.times do
  Student.create(name: Faker::Name.name, turing_module_id: be3.id)
end


# Zoom Meetings
zoom_meeting_1 = ZoomMeeting.create!(meeting_id: "12345678901",
                    title: "Test Meeting 1 For BE Mod 1",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 14:00:00.000000000 UTC +00:00",
                    duration: 60)
zoom_meeting_2 = ZoomMeeting.create!(meeting_id: "12345678902",
                    title: "Test Meeting For 2 For BE Mod 1",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 14:30:00.000000000 UTC +00:00",
                    duration: 90)
zoom_meeting_3 = ZoomMeeting.create!(meeting_id: "12345678903",
                    title: "Test Meeting 1 For For BE Mod 2",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 15:00:00.000000000 UTC +00:00",
                    duration: 120)
zoom_meeting_4 = ZoomMeeting.create!(meeting_id: "12345678904",
                    title: "Test Meeting 2 For BE Mod 2",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 14:00:00.000000000 UTC +00:00",
                    duration: 60)
zoom_meeting_5 = ZoomMeeting.create!(meeting_id: "12345678905",
                    title: "Test Meeting 1 For For FE Mod 1",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 14:30:00.000000000 UTC +00:00",
                    duration: 90)
zoom_meeting_6 = ZoomMeeting.create!(meeting_id: "12345678906",
                    title: "Test Meeting 2 For For FE Mod 1",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 15:00:00.000000000 UTC +00:00",
                    duration: 120)
zoom_meeting_7 = ZoomMeeting.create!(meeting_id: "12345678907",
                    title: "Test Meeting 1 For FE Mod 2",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 14:00:00.000000000 UTC +00:00",
                    duration: 60)
zoom_meeting_8 = ZoomMeeting.create!(meeting_id: "12345678908",
                    title: "Test Meeting 2 For For FE Mod 2",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 14:30:00.000000000 UTC +00:00",
                    duration: 90)
zoom_meeting_9 = ZoomMeeting.create!(meeting_id: "12345678909",
                    title: "Test Meeting 1 For FE Mod 2",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 14:00:00.000000000 UTC +00:00",
                    duration: 60)
zoom_meeting_10 = ZoomMeeting.create!(meeting_id: "12345678900",
                    title: "Test Meeting 2 For For FE Mod 2",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 14:30:00.000000000 UTC +00:00",
                    duration: 90)
zoom_meeting_11 = ZoomMeeting.create!(meeting_id: "12345678910",
                    title: "Test Meeting For For Combined Mod 4",
                    start_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                    end_time: "Tue, 31 Oct 2023 15:00:00.000000000 UTC +00:00",
                    duration: 120)


# Zoom Aliases
7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_1.id, turing_module_id: be1.id)
end

7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_2.id, turing_module_id: be1.id)
end

7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_3.id, turing_module_id: be2.id)
end

7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_4.id, turing_module_id: be2.id)
end

7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_5.id, turing_module_id: fe1.id)
end

7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_6.id, turing_module_id: fe1.id)
end

7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_7.id, turing_module_id: fe2.id)
end

7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_8.id, turing_module_id: fe2.id)
end

7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_9.id, turing_module_id: fe3.id)
end

7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_10.id, turing_module_id: be3.id)
end

7.times do
  ZoomAlias.create!(name: Faker::Name.name, zoom_meeting_id: zoom_meeting_11.id, turing_module_id: mod4.id)
end


# Attendances
att1 = Attendance.create!(turing_module_id: be1.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_1.id,
                          end_time: "Tue, 31 Oct 2023 14:00:00.000000000 UTC +00:00")

att2 = Attendance.create!(turing_module_id: be1.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_2.id,
                          end_time: "Tue, 31 Oct 2023 14:30:00.000000000 UTC +00:00")

att3 = Attendance.create!(turing_module_id: be2.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_3.id,
                          end_time: "Tue, 31 Oct 2023 15:00:00.000000000 UTC +00:00")

att4 = Attendance.create!(turing_module_id: be2.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_4.id,
                          end_time: "Tue, 31 Oct 2023 14:00:00.000000000 UTC +00:00")

att5 = Attendance.create!(turing_module_id: fe1.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_5.id,
                          end_time: "Tue, 31 Oct 2023 14:30:00.000000000 UTC +00:00")

att6 = Attendance.create!(turing_module_id: fe1.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_6.id,
                          end_time: "Tue, 31 Oct 2023 15:00:00.000000000 UTC +00:00")

att7 = Attendance.create!(turing_module_id: fe2.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_7.id,
                          end_time: "Tue, 31 Oct 2023 14:00:00.000000000 UTC +00:00")

att8 = Attendance.create!(turing_module_id: fe2.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_8.id,
                          end_time: "Tue, 31 Oct 2023 14:30:00.000000000 UTC +00:00")

att9 = Attendance.create!(turing_module_id: fe3.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_9.id,
                          end_time: "Tue, 31 Oct 2023 14:30:00.000000000 UTC +00:00")

att10 = Attendance.create!(turing_module_id: be3.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_10.id,
                          end_time: "Tue, 31 Oct 2023 14:30:00.000000000 UTC +00:00")

att11 = Attendance.create!(turing_module_id: mod4.id,
                          user_id: 1,
                          attendance_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00",
                          meeting_type: "ZoomMeeting",
                          meeting_id: zoom_meeting_11.id,
                          end_time: "Tue, 31 Oct 2023 15:00:00.000000000 UTC +00:00")


# student_attendances
5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att1.id,
                            duration: rand(0..60),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end

5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att2.id,
                            duration: rand(0..90),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end

5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att3.id,
                            duration: rand(0..120),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end

5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att4.id,
                            duration: rand(0..60),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end

5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att5.id,
                            duration: rand(0..90),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end

5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att6.id,
                            duration: rand(0..120),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end

5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att7.id,
                            duration: rand(0..60),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end

5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att8.id,
                            duration: rand(0..120),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end

5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att9.id,
                            duration: rand(0..120),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end

5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att10.id,
                            duration: rand(0..120),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end

5.times do
  StudentAttendance.create!(status: rand(0..2),
                            student_id: Student.pluck(:id).sample,
                            attendance_id: att11.id,
                            duration: rand(0..120),
                            join_time: "Tue, 31 Oct 2023 13:00:00.000000000 UTC +00:00")
end