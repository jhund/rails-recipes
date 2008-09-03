class ApplicationController < ActionController::Base

  around_filter :set_request_parameters

private

  # stores parameters for current request
  def set_request_parameters
    Person.current = current_person
    Conference.current = Conference.new
    # You would also set the time zone for Rails time zone support here:
    # Time.zone = Person.current.time_zone
    
    yield
    
    # TODO: do I need to reset current here? Is this unnecessary?
    Person.current = nil
    Conference.current = nil
  end

end