class ApplicationController < ActionController::Base

  include AuthenticatedSystem
  before_filter :login_from_cookie

  ...

private

  # handle exceptions
  def rescue_action(e)
    case e
    when PermissionViolation
      if logged_in?
        flash[:warning] = %(You do not have permission to access the requested resource.)
        redirect_to :back
      else
        flash[:warning] = %(Please login to access this resource.)
        store_location
        redirect_to login_path
      end
    else
      super
    end
  end

end
