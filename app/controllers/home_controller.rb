class HomeController < ApplicationController

  def index
  	@users_today = User.where("extract(month from birthday) = ? AND extract(day from birthday) = ?", Date.today.strftime('%m'), Date.today.strftime('%d'))
  	@users_incoming = User.all.select do | user |
  		user.birthday && (user.birthday.yday - Date.today.yday) < 7 && (user.birthday.yday - Date.today.yday) >= 1
  	end
  end

  def coming_soon
  end
end
