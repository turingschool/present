desc "Find and correct all duplicate instances of populi_id for students"
task clean_duplicate_students: :environment do  
  Student.pluck(:populi_id).uniq.each do |populi_id|
    puts "Checking populi id #{populi_id}"
    student_ids = Student.where(populi_id: populi_id).order(created_at: :desc).pluck(:id)
    if student_ids.count == 1
      puts "No duplicates of this populi id found."
    else
      puts "Found duplicates of this populi id."
      primary_student_id = student_ids.shift
      puts "Using student id=#{primary_student_id} as the Primary Student Record."
      puts "Duplicate student records to be deleted: #{student_ids.join(" ,")}"
      puts "Updating SlackPresenceChecks to reference the Primary Student Record instead of a duplicate."
      slack_checks = SlackPresenceCheck.where(student_id: student_ids)
      slack_checks.update_all(student_id: primary_student_id)
      puts "Updating StudentAttendances to reference the Primary Student Record instead of a duplicate."
      student_attendances = StudentAttendance.where(student_id: student_ids)
      student_attendances.update_all(student_id: primary_student_id)
      puts "Updating ZoomAliases to reference the Primary Student Record instead of a duplicate."
      zoom_aliases = ZoomAlias.where(student_id: student_ids)
      zoom_aliases.update_all(student_id: primary_student_id)
      puts "Deleting duplicate student records"
      Student.destroy(student_ids)
    end
    puts "Continuing..."

  end
end
