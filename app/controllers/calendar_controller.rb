class CalendarController < ApplicationController

  def index
    @key = APP_CONFIG['calendar']['key']
    @groups = APP_CONFIG['calendar']['groups']
    @calendars = APP_CONFIG['calendar']['list']
    @default_cals = APP_CONFIG['calendar']['default'].values_at('all', current_user.promo).flatten
  end
end
