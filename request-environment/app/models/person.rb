class Person < ActiveRecord::Base
  
  #--------------------------------------------------------------------------------------------------------------
  # CLASS METHODS
  #--------------------------------------------------------------------------------------------------------------

  def self.current
    Thread.current[:person]
  end
  
  def self.current=(person)
    raise(ArgumentError, "Invalid person. Expected an object of 'class Person', got #{person.inspect}") unless person.is_a?(Person)
    Thread.current[:person] = person
  end
  
end
