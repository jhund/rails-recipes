---
layout: default
---

{% include project_navigation.html %}

<div class="page-header">
  <h2>Permissions and user roles</h2>
</div>


This pattern helps you manage permissions in your app in a simple and robust way.

In this example we define access permissions on the User class in our app:

### 1. Include the 'HasPermissions' concern in your User class

```ruby
# app/models/user.rb
class User < ActiveRecord::Base

  include User::HasPermissions

  # ...

end
```

### 2. Define the permissions in a Concern

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
    # Note: Since these permission methods get called a lot, we try to make
    # them as efficient as possible by first checking the conditions that
    # don't require loading of additional data:
    self == actor || actor.is_admin? || managers.include?(actor)
  end

  def viewable_by?(actor)
    self == actor || \
    actor.is_admin? || \
    managers.include?(actor)
  end

end
```

### 3. Check permissions in your controller

```ruby
# app/controllers/users_controller.rb
class UserController < ApplicationController

  def show
    @user = User.find(params[:id])
    raise YourApp::AuthorizationError  unless @user.viewable_by?(current_user)
    # ...
  end

  def edit
    @user = User.find(params[:id])
    raise YourApp::AuthorizationError  unless @user.updatable_by?(current_user)
    # ...
  end

  def update
    @user = User.find(params[:id])
    raise YourApp::AuthorizationError  unless @user.updatable_by?(current_user)
    # ...
  end

  def destroy
    @user = User.find(params[:id])
    raise YourApp::AuthorizationError  unless @user.destroyable_by?(current_user)
    # ...
  end
end
```

### 4. Rescue AuthorizationErrors in your ApplicationController

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base

  # ...

  rescue_from 'YourApp::AuthorizationError' do
    redirect_to(
      request.env["HTTP_REFERER"] || root_path,
      :alert => "You do not have permission to perform the requested action."
    )
  end

  # ...

end
```

### 5. Define a custom error in initializers

```ruby
# config/initializers/custom_errors.rb
module YourApp
  class AuthorizationError < StandardError; end
end
```
