# This module provides methods to check permissions
# in a restful way include 'has_restful_permissions' in a
# resource class to plug in the default rules.
# Then customize the permission rules by overriding
# 'viewable_by?', etc. where necessary.
#
# Copyright 2008 by Jo Hund, http://clearcove.ca
#
# The responsibility to grant access lies entirely with the resource.
#
# Example uses:
#
# def viewable_by?(actor)
#   # anybody can view this resource
#   true
# end
#
# def creatable_by?(actor)
#   # anybody who is logged in
#   actor.is_a?(Person)
# end
#
# def updatable_by?(actor)
#   # logged in, has admin role or owns this resource
#   actor.is_a?(Person) && (actor.is_admin || self.owned_by?(actor))
# end
#
# These are just the basic CRUD operations. Sometimes, when you have
# non-REST actions on your resources, you might need additional 
# permission rules that are specific to your business logic.
# Examples: is_refundable_by, is_transferrable_by, etc.
#
# Exception to raise on permission violations
class PermissionViolation < StandardError; end

module HasRestfulPermissions

  # call this in resource class
  def has_restful_permissions
    extend  ClassMethods
    include InstanceMethods
  end

  module InstanceMethods

    # permission rules, override these in the resource class

    # Returns true if actor can create this new instance.
    # I decided to make this an instance method as opposed to a
    # class method because sometimes you need to look at the state
    # of the newly instantiated object or its related objects
    # to decide whether the current user is permitted to create it
    def creatable_by?(actor)
      actor.is_a?(Person)
    end

    # Returns true if actor can destroy this resource.
    def destroyable_by?(actor)
      actor.is_a?(Person) && self.owned_by?(actor)
    end

    # Returns true if actor can update this resource.
    def updatable_by?(actor)
      actor.is_a?(Person) && self.owned_by?(actor)
    end

    # Returns true if actor can view this resource.
    def viewable_by?(actor)
      actor.is_a?(Person)
    end

    # Returns true if actor owns this resource.
    # Expresses a control/ownership association.
    # Expects actor to be a Person (usually checked for in other
    # permission methods before this method is called)
    def owned_by?(actor)
      # defaults to false. Override if resource has owner
      true
    end

  end

  module ClassMethods
    # Returns true if actor can view a list of resources of this class.
    def listable_by?(actor)
      actor.is_a?(Person)
    end

    # you might expect 'creatable_by?' in here as well,
    # see comment in instance method
  end

end

ActiveRecord::Base.send :extend, HasRestfulPermissions
