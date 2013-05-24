---
layout: default
nav_id: how_to_change_objects
---

<div class="page-header">
  {% include site_navigation.html %}
  <h2>How to change objects</h2>
</div>


Rails has some awesome magic that allows us to build apps very quickly. The Rails
Way is very useful during the initial stages of development, and for simple
use cases. However for more complex scenarios, I prefer to use Object Oriented
best practices like Service Objects.

The flow chart below helps you decide what the best approach is in a given
situation by looking at two criteria:

> * How many objects will you change?
> * What additional processing is required?

<p class="unconstrained">
  <img src="/images/how_to_change_objects.png" alt="Flow chart for how to change objects" class="img-polaroid" />
</p>

<div class="side_note_right" style="width: auto;">
  <a href="/images/how_to_change_objects_in_rails.pdf">
    Download the guide as PDF<br/>
    <img src="/images/how_to_change_objects_in_rails_pdf_thumbnail.png" alt="Flow chart for how to change objects" class="img-polaroid" />
  </a>
</div>

### How many objects will you change?

Are you working with input data for a single object, or for multiple ones? This
criterion helps you decide whether to use regular resource forms, or nested
forms.

NOTE: We don't look at how many objects will eventually be affected; that will
be dealt with under additional processing.

#### Change a single object

Attributes for a single object are given.

#### Change multiple objects

Attributes for multiple objects are given. E.g., changing a user
and some of the user's projects with a single form submission.

### What additional processing is required?

This question is concerned with the complexity of the change. E.g., what else
needs to be done as a consequence of this change? What other resources are
involved?

#### No additional processing

All we do is change the attribute and nothing else.

#### Simple processing

We do some very simple processing around the change. E.g., we sanitize some data
or compute some dependent values. ActiveRecord callbacks are suitable in this
scenario, as long as they reference only internal state and no other objects.

#### Complex processing

Involves one or more of the following:

* The process touches other objects.
* The process uses a 3rd party service.
* There are multiple processing steps and a few places in the process where
  things can go wrong.
* There are several possible paths to take during the process, depending on
  the input data.

The various approaches
----------------------

### Rails magic

Example scenario:

> Update @user.accepted_tos after user accepts Terms of Service.

Use the vanilla Rails Way:

* Model: A standard ActiveRecord based class:

    ```ruby
    # app/models/user.rb
    class User < ActiveRecord::Base
    end
    ```
* View: A standard resource form:

    ```erb
    <%# app/views/users/edit.html.erb %>
    <% form_for @user do |f| %>
      <%= f.check_box :accepted_tos %> I accept the ToS
    <% end %>
    ```
* Controller: A standard RESTful controller:

    ```ruby
    # app/controllers/users_controller.rb
    class UserController < ApplicationController
      def update
        @user = User.find(params[:id])
        if @user.update_attributes(params[:user])
          redirect_to user_path(@user)
        else
          render :action => 'edit'
        end
      end
    end
    ```

### ActiveRecord callbacks

Example scenario:

> Before updating @user, strip whitespace from email.

Use the vanilla Rails way with ActiveRecord callbacks.

<div class="alert">
  <p><strong>Important!</strong></p>
  <p>
    Callbacks should use internal state only. There should be NO
    references (read or write) to external objects or services.
  </p>
  <p>
    Read this blog post for more information:
    <a href="http://samuelmullen.com/2013/05/the-problem-with-rails-callbacks/">The Problem with Rails Callbacks</a>
  </p>
</div>

* Model: A standard ActiveRecord based class with callbacks.

    ```ruby
    # app/models/user.rb
    class User < ActiveRecord::Base

      before_save :strip_whitespace_from_email

      def strip_whitespace_from_email
        self.email = email.strip
      end

    end
    ```
* View: A standard resource form for @user
* Controller: A standard RESTful controller for @user

More information on callbacks:

* Rails API: [ActiveRecord::Callbacks](http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html)
* [The Problem with Rails Callbacks](http://samuelmullen.com/2013/05/the-problem-with-rails-callbacks/)


### ActiveRecord nested attributes

Example scenario:

> Update @user and delete some of @user's projects.

Use the vanilla Rails way with nested attributes:

* Model: A standard ActiveRecord based class with nested attributes:

    ```ruby
    # app/models/user.rb
    class User < ActiveRecord::Base

      has_many :projects, :dependent => :destroy
      accepts_nested_attributes_for :projects,
                                    :allow_destroy => true

    end
    ```
* View: A standard resource form with `fields_for`:

    ```erb
    <%# app/views/users/edit.html.erb %>
    <% form_for @user do |f| %>
      <%= f.check_box :accepted_tos %>
      <%= f.fields_for :projects do |project_fields| %>
        Name: <%= project_fields.text_field :name %>
        <%= project_fields.check_box :_destroy %> Delete
      <% end %>
    <% end %>
    ```
* Controller: A standard RESTful controller for @user.

More information on nested attributes:

* Rails API: [ActiveRecord::NestedAttributes::ClassMethods](http://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html)
* Rails API: [ActionView::Helpers::FormHelper#fields_for](http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for)
* [Complex Rails Forms with Nested Attributes](http://rubysource.com/complex-rails-forms-with-nested-attributes/)

### Service Object

Example scenario:

> Import several users and their projects from a spreadsheet.

Create a Service Object for importing users and use it for the form and
controller. Please see
[7 Patterns to Refactor Fat ActiveRecord Models](http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/)
for more information on how to use Service Objects.

* Model: A PORO (Plain Old Ruby Object) service object:

    ```ruby
    # app/models/user_import.rb
    class UserImport
      # Please see the linke above for more information
      # on Service Objects.
    end
    ```
* View: A resource view for the service object:

    ```erb
    <%# app/views/user_imports/new.html.erb %>
    <% form_for @user_import do |f| %>
      Spreadsheet to import: <%= f.file_field :user_list %>
    <% end %>
    ```
* Controller: A RESTful controller for the service object:

    ```ruby
    class UserImportsController < ApplicationController
      # Use regular REST actions on the Service Object.
    end
    ```
    Note: If there are several possible outcomes, or several places
    where things can go wrong, then you might consider using
    [Outcome.rb](/pages/outcome.html) as the Service Object's return value.

More information on Service Objects:

* [7 Patterns to Refactor Fat ActiveRecord Models](http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/).
* [Service Objects: What They Are, and When to Use Them](http://stevelorek.com/service-objects.html).
* [Service classes as an alternative to observers/callbacks](http://solnic.eu/2012/07/09/single-responsibility-principle-on-rails-explained.html)

Other scenarios to consider
-----------------

* How to handle AR touch `updated_at` column on `belongs_to`
* Isolate ActiveRecord for fast tests.
* Message queues for asynchronous workers.
* outcome.rb for complex return values
* Is there any place for `after_...` AR callbacks? Are they a code smell?

Further reading
---------------

* [7 Patterns to Refactor Fat ActiveRecord Models](http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/).
* [Service Objects: What They Are, and When to Use Them](http://stevelorek.com/service-objects.html).
* [Rails, Models and Business Logic via wekeroad.com](http://wekeroad.com/2011/10/14/rails-models-and-business-logic)
* [an experimental approach to presenters, interactors and repositories](https://github.com/jasonroelofs/raidit)
* [Mutations: Putting SOA on Rails for security and maintainability](https://developer.uservoice.com/blog/2013/02/27/introducing-mutations-putting-soa-on-rails-for-security-and-maintainability/)
* [5 simple rules to good OO in Rails](http://thunderboltlabs.com/posts/5-simple-rules-to-good-oo-in-rails)
* [DCI, Concerns and Readable Code](http://blog.codeclimate.com/blog/2012/12/19/dci-concerns-and-readable-code/)
* [Models, Roles, Decorators, and Interactions -- A modest proposal for a toned done version of DCI that isn't as janky as Concerns.](https://gist.github.com/4341122)
* [The Tortoise and the Hare: Hexagonal Rails and Service Objects](http://www.foobarsoftwares.com/the_tortoise_and_the_hare)
* [Service classes as an alternative to observers/callbacks](http://solnic.eu/2012/07/09/single-responsibility-principle-on-rails-explained.html)
* [Architecture the Lost Years - Robert Martin](http://confreaks.com/videos/759-rubymidwest2011-keynote-architecture-the-lost-years)
* [How to Stop Using Nested Forms](http://matthewrobertson.org/blog/2012/09/20/decoupling-rails-forms-from-the-database/)
