module ApplicationHelper
  def pretty_time(datetime)
    datetime.in_time_zone('Mountain Time (US & Canada)').strftime('%l:%M %p').strip
  end

  def pretty_date(datetime)
    datetime.in_time_zone('Mountain Time (US & Canada)').to_date.to_fs(:long_ordinal)
  end
end