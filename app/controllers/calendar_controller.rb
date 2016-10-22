class CalendarController < ApplicationController

  def index
    @calendars = APP_CONFIG['calendar']['list']
    @key = APP_CONFIG['calendar']['key']
    
    default_cals = APP_CONFIG['calendar']['default']
    [default_cals['all'], default_cals[current_user.promo]].compact.each { |elt|
        elt.each { |group_key, group|
            group.each { |cal|
                @calendars[group_key][cal]['default'] = 'on'
            }
        }
    }
  end
end
