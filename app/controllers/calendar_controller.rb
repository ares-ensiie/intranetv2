class CalendarController < ApplicationController

  def index
    @cur_prom = current_user.promo
    @calendars = APP_CONFIG['calendar']['list']
    @key = APP_CONFIG['calendar']['key']
    @default = APP_CONFIG['calendar']['default']
  end

end
