---
layout: default
nav_id: permissions_and_user_roles
---

<div class="page-header">
  {% include site_navigation.html %}
  <h2>Permissions and user roles</h2>
</div>

<div class="alert">
  <p><strong>Outdated!</strong></p>
  <p>This recipe is outdated. Please see newer recipes for alternatives.</p>
</div>

This pattern helps you manage permissions in your app in a simple and robust way.
In this example we define access permissions on the `User` class:

1. Define the permissions in a concern:

    ```ruby
    # app/models/user/has_permissions.rb
    module User::HasPermissions

      extend ActiveSupport::Concern

      module ClassMethods

        def creatable_by?(actor)
          true # anybody can sign up for an account
        end

        def listable_by?(actor)
          actor.is_admin?
        end

      end

      def creatable_by?(actor)
        self.class.creatable_by?(actor)
      end

      def destroyable_by?(actor)
        return false  if self == actor # can't destroy self
        actor.is_admin?
      end

      # Users can edit their own record,
      # admins can edit any user, and
      # managers can update the users they manage
      def updatable_by?(actor)
        # Note: Since these permission methods get called a lot,
        # we try to make them as efficient as possible by first
        # checking the conditions that don't require loading of
        # additional data:
        self == actor || \
        actor.is_admin? || \
        manager == actor
      end

      def viewable_by?(actor)
        self == actor || \
        actor.is_admin? || \
        manager == actor
      end

    end
    ```
2. Include the `HasPermissions` concern in the `User` class:

    ```ruby
    # app/models/user.rb
    class User < ActiveRecord::Base

      include User::HasPermissions
      belongs_to :manager
      # ...

    end
    ```
3. Check permissions in the controller:

    ```ruby
    # app/controllers/users_controller.rb
    class UserController < ApplicationController

      def show
        @user = User.find(params[:id])
        unless @user.viewable_by?(current_user)
          raise YourApp::AuthorizationError
        end
        # ...
      end

      def edit
        @user = User.find(params[:id])
        unless @user.updatable_by?(current_user)
          raise YourApp::AuthorizationError
        end
        # ...
      end

      def update
        @user = User.find(params[:id])
        unless @user.updatable_by?(current_user)
          raise YourApp::AuthorizationError
        end
        # ...
      end

      def destroy
        @user = User.find(params[:id])
        unless @user.destroyable_by?(current_user)
          raise YourApp::AuthorizationError
        end
        # ...
      end
    end
    ```
4. Rescue `AuthorizationError` in `ApplicationController`:

    ```ruby
    # app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base

      # ...
      rescue_from 'YourApp::AuthorizationError' do
        redirect_to(
          request.env["HTTP_REFERER"] || root_path,
          :alert => "You are not authorized for this action."
        )
      end
      # ...

    end
    ```
5. Define a custom error in initializers

    ```ruby
    # config/initializers/custom_errors.rb
    module YourApp
      class AuthorizationError < StandardError; end
    end
    ```
