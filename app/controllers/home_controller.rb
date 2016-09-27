class HomeController < ApplicationController

  def index
  	@users_today = User.where("extract(month from birthday) = ? AND extract(day from birthday) = ?", Time.zone.now.month, Time.zone.now.day)
   	@users_incoming = User.order("extract(month from birthday), extract(day from birthday), lastname, name").select do | user |
  		user.birthday && Time.zone.local(Time.zone.now.year, user.birthday.month, user.birthday.day) - Time.zone.now < 86400*6 && Time.zone.local(Time.zone.now.year, user.birthday.month, user.birthday.day) - Time.zone.now > 0
  	end
  end

  def coming_soon
  end
end
