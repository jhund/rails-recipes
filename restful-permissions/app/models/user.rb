class User < ActiveRecord::Base

  has_restful_permissions
  
  # --------------------------------------------------------
  # Permission overrides
  # --------------------------------------------------------
  def self.listable_by?(actor)
    actor.is_a?(User) && (actor.is_admin?)
  end

  def creatable_by?(actor)
    # anybody can create an account
    true
  end

  def destroyable_by?(actor)
    # no deleting of users at this point
    false
  end

  def updatable_by?(actor)
    actor.is_a?(User) && (actor.is_admin? || self.owned_by?(actor))
  end

  def viewable_by?(actor)
    actor.is_a?(User)
  end

  def owned_by?(actor)
    actor == self
  end
  
end
