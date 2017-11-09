module ApplicationHelper
  def format_amount(amount)
    money = Money.new(amount)
    money.format
  end

  def format_time(time)
    current_month = Date.today.month
    current_date = Date.today.day
    if current_date == time.day
      time.strftime("Today, %l:%M %p")
    else
      time.strftime("%A %d %B, %l:%M %p")
    end
  end

  def format_date(date)
    date.strftime("%A %d %B, %Y")
  end
end
