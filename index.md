---
layout: default
nav_id: start_page
---

<div class="page-header">
  <h1>Ruby on Rails Recipes</h1>
</div>

{% include site_navigation.html %}

A collection of recipes for solid Ruby on Rails applications. Extracted from
dozens of production apps and 10,000+ hours of deliberate Ruby on Rails practice
since 2005.


The Recipes
-----------

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


### Source code

The [source for Rails Recipes](https://github.com/jhund/rails-recipes) is on github.


### Credits

This Ruby style guide started as a fork of Christian Neukirchen's Ruby Style guide.
It has since evolved into a larger body of content.


### License

MIT licensed



### Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.



### Copyright

Copyright (c) 2010 - 2013 Jo Hund. MIT LICENSED
