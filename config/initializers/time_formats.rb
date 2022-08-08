class ActiveSupport::TimeWithZone
  def am_pm_format(strftime_args)
    strftime(strftime_args).gsub(/am/i, "a.m.").gsub(/pm/i, "p.m.")
  end

  # Mon, Jan 12
  def dow_short_date
    strftime("%a, %b %-d")
  end

  # Jan 12
  def short_date
    strftime("%b %-d")
  end

  # Jan 12 @  1:45 am
  def short_date_at_time
    strftime("%b %-d @ %l:%M %P")
  end

  # 8:40 pm (Tue 7/26)
  def dow_time
    strftime("%a %l:%M %p").gsub('  ', ' ')
  end

  # 8:40 pm (Tue 7/26)
  def time_and_day
    strftime("%l:%M %P (%a %-m/%-d)")
  end
end