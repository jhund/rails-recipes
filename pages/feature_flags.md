---
layout: default
nav_id: feature_flags
---

<div class="page-header">
  {% include site_navigation.html %}
  <h2>Feature flags</h2>
</div>

Sometimes you need to dynamically enable certain app features for a given user.
This recipe gives you nice helper methods that you can add to controllers and
views to guard features that should only be available to a subset of users:

First define the feature flag helper methods in a module.

```ruby
# app/concerns/feature_flags.rb
module FeatureFlags

  def can_impersonate_other_users?
    admin?
  end

  def sees_beta_features?
    is_staff? || is_beta_tester?
  end

  # define any other helper methods ...

end
```

Include the module in your `User` class to add the feature flag helper methods
to the current_user instance.

```ruby
# app/models/user.rb
class User < ActiveRecord::Base

  # Add feature flag methods to user instances
  include FeatureFlags

  ...

end
```

Make the feature flag helper methods available to all controller actions and
views. Delegate to current_user for easier referencing and to make it work
if no current_user is present.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base

  # Dynamically get a list of all implemented feature flags
  feature_flags = FeatureFlags.public_instance_methods
  # Delegate all feature flag methods to current_user
  delegate *feature_flags, :to => current_user, :allow_nil => true
  # Make feature flag methods available in views
  helper_method feature_flags

  ...

end
```

Guard features with conditionals that reference feature flag helper methods. Notice
that you don't need to send these messages to current_user. They are automatically
delegated to current_user with the directive in ApplicationController.

```erb
<%# app/views/users/index.html.erb %>
<h1>Users</h1>
...
<% if can_impersonate_other_users? %>
  <li><%=# ... link to impersonate a user from the user list ... %></li>
<% end %>
...
```

This recipe allows you to test new features internally and when you're ready
to launch, all you do is to update the feature flag method to return `true`
so that everybody will see the new feature. Then in a next step you can remove
the feature flag helper method and all guard clauses in the views.

### Credits

This recipe is inspired by
[Brandon Keepers' talk about Ruby at Github](http://opensoul.org/blog/archives/2013/04/29/ruby-at-github/)
(about 3/4 through the presentation).
