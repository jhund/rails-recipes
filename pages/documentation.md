---
layout: default
nav_id: documentation
---

<div class="page-header">
  <h2>Documentation</h2>
</div>

{% include site_navigation.html %}

Pretty much any serious Rails project will require some kind of documentation
that reminds us of:

* How to run a manual database query for reporting.
* Why we chose one gem over another.
* The thought process for developing a complex piece of functionality.
* ...

We prefer to have this documentation in the app and under version control.

Solution:

* Text files in `doc/`.
* Formatted with Markdown.
* Tracked in git.
* Ongoing development notes go into `doc/dev_notes/`. They are prefixed with
  a date stamp for chronological sorting.
* How-tos for repetitive tasks go into `doc/how_to/`. They can be text documents,
  ruby source code or SQL statements. Use `.md`, `.rb`, and `.sql` extensions
  accordingly.

Here is an example `doc` folder:

```
+ [app_root]
  + doc
    + dev_notes
      20121003_choosing_a_gem_for_pagination.md
      20130511_dynamic_navigation_in_a_jekyll_site.md
    + how_to
      create_demo_data.rb
      deploy_to_production.md
      query_activities_longer_than_24_hrs.sql
      update_git_submodules.md
```

Once the dev_notes grow too large, we move older ones into `doc/dev_notes/archive`.
