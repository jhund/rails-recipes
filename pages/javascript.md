---
layout: default
nav_id: javascript
---

<div class="page-header">
  <h2>Javascript Recipes</h2>
</div>

{% include site_navigation.html %}

// Further reading
// ===============
//
// * [Isobar's Frontent Style Guide](http://molecularvoices.molecular.com/standards/)
// * [Google's Javascript Style Guide](http://google-styleguide.googlecode.com/svn/trunk/javascriptguide.xml)

// Namespace your app's custom code:

if (typeof ClearCove === 'undefined') {
    ClearCove = {};
}

ClearCove.SomeCustomModule = {

}
