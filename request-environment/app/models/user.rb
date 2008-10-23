class User < ActiveRecord::Base
  
  #-----------------------------------------------------------------------------------------------------
  # CLASS METHODS
  #-----------------------------------------------------------------------------------------------------

  def self.current
    Thread.current[:user]
  end
  
  def self.current=(user)
    raise(ArgumentError,
        "Invalid user. Expected an object of class 'User', got #{user.inspect}") unless user.is_a?(User)
    Thread.current[:user] = user
  end
  
end
