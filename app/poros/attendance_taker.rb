class AttendanceTaker
  def self.take_attendance(attendance, user)
    sheet_data = GoogleSheetsService.get_sheet_matrix(attendance.turing_module, user)
    sheet_matrix = sheet_data[:values]
    # require 'pry';binding.pry
    zoom_names = sheet_matrix[1]
    # require 'pry';binding.pry
    # MegsZoomClass.whatever(zoom_names, attendance.zoom_meeting_id)
    participant_report = ZoomFacade.past_participants_in_meeting(attendance.zoom_meeting_id, zoom_names)
    if participant_report
      # set a background worker to start 5 minutes after the meeting end time
    end
    datetime = DateTime.parse('2021-09-21T15:00:00Z')
    am_or_pm = am_or_pm(datetime)
    column_index = find_column_index(sheet_matrix, datetime)
    zoom_names.each_with_index do |name, row_index|
      next if row_index == 0
      sheet_matrix[column_index][row_index] = participant_report[:participants][name].status
    end
    response = GoogleSheetsService.update_sheet(attendance.turing_module, user, sheet_matrix)
  end

  def self.am_or_pm(datetime)
    datetime.in_time_zone('Mountain Time (US & Canada)').hour <= 12 ? 'AM' : 'PM'
  end

  def self.formatted_date(datetime)
    datetime.strftime('%m/%d/%y')
  end

  def self.date_column_identifier(datetime)
    am_or_pm(datetime) + " " + formatted_date(datetime)
  end

  def self.find_column_index(sheet_matrix, meeting_start_datetime)
    header_match = date_column_identifier(meeting_start_datetime)
    sheet_matrix.find_index do |column|
      column.first == header_match
    end
  end
end
