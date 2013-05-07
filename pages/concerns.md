---
layout: default
---

{% include project_navigation.html %}

<div class="page-header">
  <h2>Concerns</h2>
</div>

Rails has had great support for `Concerns` since version 3.
There is a bit of controversy around this topic. I agree that in some cases
it's better to use composition than mixing in modules.

However in many cases where you just can't take the golden path because of some
constraints you are subject to, it makes perfect sense to re-organize your fat
model into concerns that are both cohesive and have a single responsibility.

The nice thing about concerns is that it's a very low risk refactor that can
provide great value and clarity.

Below I illustrate what such a refactor can look like:

![How to use concerns to refactor and test a fat model](/images/concerns_progression.png)

### A: Big fat legacy Rails ActiveRecord User model

It is a junk drawer of methods, both AR specific and domain specific.
It has > 1,000 LOC. It is a nightmare to step into.
In our example, there are methods representing 4 concerns:

1. Users receive emails.
2. Users have permissions.
3. Users have presenters for display.
4. Users have profile settings.

Each icon in the diagram represents a method from one of the concerns.

### B: Slim model with concerns mixed in

We have removed all domain specific methods into cohesive concerns. We include
these concerns into the AR User model, so at runtime nothing really changes.
The User model still has all the same methods. These are the concerns we extracted:

* User::ReceivesEmails
* User::HasPermissions
* User::HasPresenter
* User::HasProfileSettings

Benefits:

* It's easy to find methods and to reason about their responsibility
  and how they fit into the app's overall structure.
* You can try out different clusters of methods without affecting runtime
  behavior. This is a very low risk and high yield refactor.
* You can re-use behavior more easily between classes.

### C: Testing a domain concern

Now that our concern is contained in a cohesive package, we can take it and
do things with it in isolation. E.g., testing it. We just include it in a `Test::User`
class, stub a few dependencies, and now we can have very fast and simple
unit tests. We don't need to satisfy everything that was part of the Fat User
model in scenario A:

* AR validations
* AR associations
* AR call_backs
* state_machines
* file attachments with ImageMagick (Oh my...)
* etc.

We can test just the behavior around Permissions.

More info on Concerns
---------------------

* Store concerns that belong to a resource under that resource:
  E.g., `User::HasPermissions` goes to `app/models/user/has_permissions.rb`.
  Concerns that cut across many resources go into `/app/concerns/`:
  E.g., `Presenter::DateTime`.
* Add the below to your auto_load_paths in application.rb (NOTE: this is not
  required any more in Rails4): `config.autoload_paths += "#{ config.root }/app/concerns"`
* Naming convention: If you are adding shared behavior to a polymorphic
  association, call it `CommentableMixin` where `:commentable` is the name
  of the polymorphic association.
* Gotcha: Don't use three subsequent upper case letters when naming your classes.
    * Will **NOT** work: `IORatio`, with file name `i_o_ratio.rb`. For some
      reason, Rails won't load the module.
    * **WILL** work: `IoRatio`, with file name `io_ratio.rb`.

Since Rails3 there is now a canonical way to include modules into Classes:
`ActiveSupport::Concern`. Use it like so:

```ruby
module User::HasPermissions

  extend ActiveSupport::Concern

  included do
    scope :disabled, where(:disabled => true)
  end

  module ClassMethods
    ...
  end

  module InstanceMethods
    ...
  end

end
```

Then include it in a class you want to add the behavior to:

```ruby
class User < ActiveRecord::Base

  include User::HasPermissions

  ...

end
```
