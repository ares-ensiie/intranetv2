class CalendarController < ApplicationController

  def index
    @calendars = APP_CONFIG['calendar']['list']
    @key = APP_CONFIG['calendar']['key']
    
    d = APP_CONFIG['calendar']['default']
    [d['all'], d[current_user.promo]].compact.each { |e|
        e.each { |gk, g|
            g.each { |c|
                @calendars[gk][c]['default'] = 'on'
            }
        }
    }
  end
end
