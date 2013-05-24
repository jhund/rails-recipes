---
layout: default
nav_id: naming_and_organizing_your_user_facing_code
---

<div class="page-header">
  {% include site_navigation.html %}
  <h2>Naming and organizing your user facing code</h2>
</div>

This pattern helps you organize your Controller and View code with the following
objectives in mind:

* Align your code concerns with the domain concerns.
* Bring the domain use cases to the forefront, so that it is obvious what your
  app does.
* Eliminate conditionals in your controllers and views as much as possible to
  make your code easy to reason about and so simple that you don't really need
  tests. (We're trading a bit of duplication for simplicity of code.)

Benefits:

* Permission checking is super simple: one before_filter in each name space's
  base controller. See below for an example.
* Hardly any conditionals in your views. Since you create views specifically
  for each role, you can rely on the controller's permission checking, and
  you don't need to make your views modal, based on a user's role. You know
  that anybody viewing a template in the 'admin' namespace is an admin.


## Domain roles

We start by identifying the user roles that will use your app. Everything will
be organized around these roles.

Example: In an online training application we have the following roles:

* Admin: Manages user roles, app settings, etc.
* Facilitator: Facilitates a training cohort, can see students' progress and data.
* Curriculum editor: Works on course ware, edits and reviews training materials.
* Registrar: responsible for setting up training cohorts, registration, payments.
* Student: Participates in the online training.


These five roles cover every use case of the app. We use them to organize our
code at the top level. These are concerns that are unlikely to change. These
roles have probably existed in your client's organization for a long time, and
it might require years of negotiations with the Union to change them. So they
are a prime candidate as the primary category for organizing your code.


Alternative categorization dimensions:

* ActiveRecord models: This is a very common way of primarily organizing the
  code in Rails apps. The problem is that they are implementation details that
  might change, and often they are not the concepts your clients think and talk
  about.


## Controller organization

Below is an example file system view of your `app/controllers` folder:

```
* admin
  * base_controller.rb
  * facilitators_controller.rb
  * reports_controller.rb
  * settings_controller.rb
* anonymous_controller.rb
* application_controller.rb
* curriculum_editor
  * base_controller.rb
  * courses_controller.rb
  * tasks_controller.rb
* facilitator
  * base_controller.rb
  * students_controller.rb
  * reports_controller.rb
* registrar
  * base_controller.rb
  * groups_controller.rb
  * reports_controller.rb
  * students_controller.rb
* student
  * base_controller.rb
  * groups_controller.rb
  * student_tasks_controller.rb
  * students_controller.rb
```

## Controller inheritance

Each controller namespace has a BaseController. In this controller you can
enforce permissions for the given role in one place and then not worry about
them in any of the child controllers and views.

Permission check is defined in base controller:

```ruby
class CurriculumEditor::BaseController < ApplicationController

  before_filter :enforce_curriculum_editor_permissions

protected

  def enforce_curriculum_editor_permissions
    raise AuthorizationError  unless current_user.is_curriculum_editor?
  end

end
```

Subclasses of base controller will inherit the permission check before filter:

```ruby
class CurriculumEditor::CoursesController < CurriculumEditor::BaseController

  def index
    ...
  end

  ...

end
```
