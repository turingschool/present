class AttendanceTaker
  def self.take_attendance(attendance, user)
    sheet_data = GoogleSheetsService.get_sheet_matrix(attendance.turing_module.google_sheet, user)
    sheet_matrix = sheet_data[:values]
    zoom_names = sheet_matrix[1]
    participant_report = ZoomFacade.past_participants_in_meeting(attendance.zoom_meeting_id, zoom_names)
    datetime = participant_report[:meeting_start_time]
    am_or_pm = am_or_pm(datetime)
    column_index = find_column_index(sheet_matrix, datetime)
    attendance_values = zoom_names.dup
    zoom_names.each_with_index do |name, row_index|
      next if row_index == 0
      attendance_values[row_index] = participant_report[:participants][name].status
    end
    attendance_values.shift
    response = GoogleSheetsService.update_column(attendance.turing_module.google_sheet, column_name(column_index), attendance_values, user)
  end

  def self.column_name(column_index)
    alphabet = ("A".."Z").to_a

    'A' * (column_index / 26) + alphabet[column_index % 26]
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
