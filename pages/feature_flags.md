---
layout: default
nav_id: feature_flags
---

<div class="page-header">
  {% include site_navigation.html %}
  <h2>Feature flags</h2>
</div>

Sometimes you need to dynamically enable certain app features for a given user.
This recipe gives you nice helper methods that you can add to views to guard
features that are only available to some users:

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

```ruby
# app/models/user.rb
class User < ActiveRecord::Base

  # Add feature flag methods to user instances
  include FeatureFlags

  ...

end
```

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

```erb
<%# app/views/users/index.html.erb %>
<h1>Users</h1>
...
<%# Guard features with conditionals that reference feature flag helper methods %>
<% if current_user.can_impersonate_other_users?
  <li><%=# ... link to impersonate a user from the user list ... %></li>
<% end %>
...
```

### Credits

This recipe is inspired by
[Brandon Keepers' talk about Ruby at Github](http://opensoul.org/blog/archives/2013/04/29/ruby-at-github/)
(about 3/4 through the presentation).
