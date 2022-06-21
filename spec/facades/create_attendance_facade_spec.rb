require 'rails_helper'

RSpec.describe CreateAttendanceFacade do
  it 'can convert join time to a status' do
    meeting_time = Time.parse("2021-12-17T16:00:00Z")
    no_show = CreateAttendanceFacade.convert_status(nil, meeting_time)
    early = CreateAttendanceFacade.convert_status(Time.parse("2021-12-17T15:48:18Z"), meeting_time)
    less_than_one_minute_late = CreateAttendanceFacade.convert_status(Time.parse("2021-12-17T16:00:18Z"), meeting_time)
    over_one_minute_late = CreateAttendanceFacade.convert_status(Time.parse("2021-12-17T16:01:18Z"), meeting_time)
    between_one_and_thirty = CreateAttendanceFacade.convert_status(Time.parse("2021-12-17T16:11:18Z"), meeting_time)
    after_thirty = CreateAttendanceFacade.convert_status(Time.parse("2021-12-17T16:31:18Z"), meeting_time)

    expect(no_show).to eq("absent")
    expect(early).to eq("present")
    expect(less_than_one_minute_late).to eq("present")
    expect(over_one_minute_late).to eq("tardy")
    expect(between_one_and_thirty).to eq("tardy")
    expect(after_thirty).to eq("absent")
  end
end
