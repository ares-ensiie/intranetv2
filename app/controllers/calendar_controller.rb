class CalendarController < ApplicationController

  def index
    # La configuration est commune à toute l'application
    # il faut la copier avant de la modifier pour ne pas
    # pas affecter les autres utilisateurs
    @calendars = APP_CONFIG['calendar']['list'].deep_dup
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
