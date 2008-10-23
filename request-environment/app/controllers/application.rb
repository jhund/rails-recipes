class ApplicationController < ActionController::Base

  before_filter :set_request_environment

private

  # stores parameters for current request
  def set_request_environment
    User.current = current_user # current_user is set by restful_authentication
    # You would also set the time zone for Rails time zone support here:
    # Time.zone = Person.current.time_zone
  end

end