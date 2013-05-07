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

However in some cases where you just can't take the golden path because of some
constraints you are subject to, it makes perfect sense to re-organize your fat
model into concerns that are both coherent and have a single responsibility.

The nice thing about concerns is that it's a very low risk refactor that can
provide great value and clarity.


* TODO: show two pictures of my son's Legos (junk drawer and sorted).
* TODO: Include diagram that shows how concerns can be tested fast and in isolation,
  vs. fat model

NOTE: the below is work in progress and will be updated very soon.

* Store modules in `/app/concerns/`, or under a model's namespace if the concern
  is specific to a model, like `User::HasPermissions`.
* Add the below to your auto_load_paths in application.rb (NOTE: not required in
  Rails4 any more):
    `config.autoload_paths += "#{ config.root }/app/concerns"`
* Naming convention: If you are adding shared behavior to a polymorphic
  association, you could call it `CommentableMixin`.
* Gotcha: Don't use three subsequent upper case letters when naming your classes.
    * Will **NOT** work: `IORatio`, with file name `i_o_ratio.rb`. For some
      reason, Rails won't load the module.
    * **WILL** work: `IoRatio`, with file name `io_ratio.rb`.

Since Rails3 there is now a canonical way to include modules into Classes:
`ActiveSupport::Concern`. Use it like so:

```ruby
module MyMixin

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
class ExtendedClass < ActiveRecord::Base

  include MyMixin

  ...

end
```

Additional Reading
------------------

* http://yehudakatz.com/2009/11/12/better-ruby-idioms/
* http://www.strictlyuntyped.com/2010/05/tweaking-on-rails-30-2.html
