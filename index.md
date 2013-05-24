---
layout: default
nav_id: start_page
---

<div class="page-header">
  {% include site_navigation.html %}
  <h1>Ruby on Rails Recipes</h1>
</div>

A collection of recipes for solid Ruby on Rails applications. Extracted from
dozens of production apps and 10,000+ hours of deliberate Ruby on Rails practice
since 2005:


#### [Concerns](pages/concerns.html)

I know, I know,... Some people are concerned when they see the `concerns` folder
in your app. Read this to find out why I think they are useful anyways.


#### [Configuration](pages/configuration.html)

The best practice to configure your app: Use ENV variables. Works for clusters,
different types of deployments, and in development mode.


#### [Documentation](pages/documentation.html)

Pretty much any serious Rails project will require some kind of documentation.
Here is a set of conventions that have worked well for me.


#### [How to change objects](pages/how_to_change_objects.html)

This guide helps you decide on the right approach when changing data. It's about
Rails magic vs. Object Oriented best practices.


#### [Naming and organizing your user facing code](pages/naming_and_organizing_your_user_facing_code.html)

Let use cases and roles drive how you organize and name your Controllers and Views.


#### [Outcome.rb](pages/outcome.html)

Advanced return values for complex processing. Includes a success indicator,
return value and user messages in a uniform interface.


#### [Permissions and user roles](pages/permissions_and_user_roles.html)

How to manage user roles and permissions.


#### [Ruby coding style guide](pages/ruby_coding_style_guide.html)

Follow this style guide to make your code easy to read and reason about.

<hr/>

<div class="row">
  <div class="span5">
    <h3>Resources</h3>
    <ul>
      <li><a href="http://rails-recipes.clearcove.ca">This Documentation</a>
      <li><a href="https://github.com/jhund/rails-recipes">Source code</a>
      <li><a href="https://github.com/jhund/rails-recipes/issues">Issues</a>
    </ul>
  </div>

  <div class="span5">
    <h3>Copyright</h3>
    Copyright (c) 2010 - 2013 Jo Hund.
  </div>
</div>
