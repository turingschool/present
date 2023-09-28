desc "Find and correct all duplicate instances of populi_id for students"
task :clean_duplicate_students, [:testing_mode_enabled] => :environment do |task, args|
  args.with_defaults(:testing_mode_enabled => true)
  testing = ActiveModel::Type::Boolean.new.cast(args[:testing_mode_enabled])
  testing_mode_confirmation(testing)
  Student.pluck(:populi_id).uniq.each do |populi_id|    
    process_populi_id(populi_id, testing)
  end
end

def process_populi_id(populi_id, testing)
  student_ids = Student.where(populi_id: populi_id).order(created_at: :desc).pluck(:id)
  unless student_ids.count == 1
    primary_student_id = student_ids.shift
    duplicate_records_message(populi_id, primary_student_id, student_ids)
    slack_checks = find_slack_presence_checks(testing, primary_student_id, student_ids)
    student_attendances = find_student_attendances(testing, primary_student_id, student_ids)
    zoom_aliases = find_zoom_aliases(testing, primary_student_id, student_ids)
    update_records(testing, primary_student_id, slack_checks, student_attendances, zoom_aliases)
    delete_duplicates(testing, student_ids)
    puts "Continuing..."
    puts
  end
end

def duplicate_records_message(populi_id, primary_student_id, duplicate_student_ids)
  puts "Found duplicates of populi_id #{populi_id}"
  puts "Using student id=#{primary_student_id} as the Primary Student Record."
  puts "Duplicate student records to be deleted: #{duplicate_student_ids.join(", ")}"      
end

def find_slack_presence_checks(testing, primary_student_id, duplicate_student_ids)
  slack_checks = SlackPresenceCheck.where(student_id: duplicate_student_ids)
  slack_check_ids = slack_checks.map(&:id)
  if slack_check_ids.empty?
    puts "No SlackPresenceChecks that reference a duplicate found"
  else
    puts "SlackPresenceChecks that reference a duplicate record: #{slack_check_ids.join(", ")}"
  end
  return slack_checks
end

def find_student_attendances(testing, primary_student_id, duplicate_student_ids)
  student_attendances = StudentAttendance.where(student_id: duplicate_student_ids)
  student_attendance_ids = student_attendances.map(&:id)
  if student_attendance_ids.empty?
    puts "No StudentAttendances that reference a duplicate found"
  else
    puts "StudentAttendances that reference a duplicate record: #{student_attendance_ids.join(", ")}"
  end
  return student_attendances
end

def find_zoom_aliases(testing, primary_student_id, duplicate_student_ids)
  zoom_aliases = ZoomAlias.where(student_id: duplicate_student_ids)
  zoom_alias_ids = zoom_aliases.map(&:id)
  if zoom_alias_ids.empty?
    puts "No ZoomAliases that reference a duplicate found"
  else
    puts "ZoomAliases that reference a duplicate record: #{zoom_alias_ids.join(", ")}"
  end
  return zoom_aliases
end

def update_records(testing, primary_student_id, slack_checks, student_attendances, zoom_aliases)
  if testing
    puts "Skipping updates because testing mode is enabled."  
  else
    puts "Updating SlackPresenceChecks to reference the Primary Student Record instead of a duplicate."
    slack_checks.update_all(student_id: primary_student_id)
    puts "Updating StudentAttendances to reference the Primary Student Record instead of a duplicate."
    student_attendances.update_all(student_id: primary_student_id)
    puts "Updating ZoomAliases to reference the Primary Student Record instead of a duplicate."
    zoom_aliases.update_all(student_id: primary_student_id)
  end
end

def delete_duplicates(testing, duplicate_student_ids)
  if testing
    puts "Skipping delete of duplicate student records because testing mode is enabled."
  else
    puts "Deleting duplicate student records"
    Student.destroy(duplicate_student_ids)
  end
end

def testing_mode_confirmation(testing)
  puts "Cleaning duplicate populi_ids in the students table"
  if testing
    puts "Testing mode is enabled."
    puts "This task will find all duplicate populi_ids and report which records would be deleted if testing mode is disabled."
    puts "Testing mode is enabled by default. To disable testing mode, pass the argument \"false\" to this task"
  else
    puts "Testing mode is disabled"
    puts "WARNING: This task will delete the duplicate student records and correct foreign key relationships in the databse"
    puts "If you would like to proceed, please enter y. Press enter to abort."
    unless gets.chomp == "y"
      exit
    end
  end
  puts
end