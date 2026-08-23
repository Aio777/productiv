# frozen_string_literal: true

module GroupRecords
  def self.group_records_by_time(records, time_attribute, time_range, group_by)
    time_range = time_range..Time.now unless time_range.nil?

    case group_by
    when :hour
      records.group_by_hour(time_attribute, series: false, range: time_range, format: '%-d %b %Y - %-k:%M').count
    when :day
      records.group_by_day(time_attribute, series: false, range: time_range, format: '%-d %B %Y').count
    when :week
      records.group_by_week(
        time_attribute,
        series: false,
        week_start: :monday,
        range: time_range
      ).count.transform_keys { |start_date| transform_date_to_week_range(start_date) }
    when :month
      records.group_by_month(time_attribute, series: false, range: time_range, format: '%B %Y').count
    end
  end

  def self.transform_date_to_week_range(date)
    "#{date.beginning_of_week.strftime('%-d %b %Y')} - #{date.end_of_week.strftime('%-d %b %Y')}"
  rescue NoMethodError => e
    Rails.logger.error "app/lib/group_records.rb - GroupRecords Error: #{e.message}"
    false
  end
end
