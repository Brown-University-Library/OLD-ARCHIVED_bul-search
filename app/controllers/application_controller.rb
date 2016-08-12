class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #make sure bdr searches render with the correct url
  def search_action_url *args
    if !args.empty? && args[0]['controller'] == 'bdr'
      bdr_index_url *args
    else
      catalog_index_url *args
    end
  end

  def int_param(symbol, default, max = nil)
    value = params[symbol]
    return default if value == nil
    if max != nil
      return [value.to_i, max].min
    end
    value.to_i
  end
end
