### Rails app architecture [wip]

The objective is to make system behavior a first class citizen in a Rails app. This means that behaviors are implemented in dedicated interaction classes and _not_ in controllers (fat controllers) or ActiveRecord models (fat models).

Rails convenience methods can handle a lot of simple cases where we just assign new attributes to the database table. However, as soon as a process has more than one step, or requires business logic, policy, or interaction with other entities, it should be modeled in a dedicated class.

The benefit is that by encapsulating each process, it becomes trivial to trigger complex processes in tests, from the console, from background jobs, and most importantly from controller actions. You're also guaranteed to use the same behavior no matter how you invoke the process.

Naming: We call them "Interactions". Other options: Process, behavior, action.

#### Guidelines

* For intermediate to advanced Rails developers who are familiar with the core rails concepts of controllers, models, views, helpers, callbacks, etc.
* This approach stays as close as possible to the Rails Way of doing things. We're not discarding or changing any of the Rails conventions.
* What we're doing: We separate out behavior from controllers and models. Skinny controllers, skinny models, fat behaviors.
* All decisions need to be chrystal clear, and not require a lot of cognitive effort when writing code if you are familiar with rails conventions.
* Explicit over magic.
* Can be adopted gradually from existing rails apps, or controller actions that start out simple and get more complicated. Then you move them to Interactions.
* Advantages:
    * Layered architecture: UI, domain model, infrastructure
    * Isolated behaviors:
        * Can be tested easily.
        * Can be invoked not just from controllers, but also from tests, background jobs, console, rake tasks.
        * Have a clearly defined interface for easy invocation. Take same arguments the corresponding controller action would expect. Map 1-to-1 to controllers and actions.

#### Application file layout

* app
    * assets
        * javascripts
            * client
                * app.js - JS bundle produced by re-frame client app in separate folder, possibly separate repo.
        * stylesheets
            * We use [BEM](http://getbem.com/) for CSS organization and naming.
            * We also use the following groupings:
                * client - for CSS specific to a client app (built using re-frame). NOTE: We use react-bootstrap on the client as it is CSS compatible with bootstrap for server rendered views. One CSS for both client and server side app.
                * components - for re-usable components, examples: data-tag, data-table, flash-notice, blank-state
                * fontawesome - for SCSS and fonts related to FontAwesome
                * shared - for app-wide shared CSS like typography, bootstrap overrides, colors, config, utils, etc.
                * vendor - vendor CSS like select2 bootstrap theme, vis-network.css
    * channels (nothing special here)
    * contexts
        * Specify the top level modules used to organize controllers, helpers, interactions, and views by contexts.
        * Currently they are empty modules. We just put them here because they are such an important concept and they need to be manifested somewhere.
        * Another benefit of putting them here is that we will catch naming conflicts with other top level classes, e.g., under models. If a module and a class with the same name exist, then a type error will be raised.
    * controllers
        * Controllers are the primary mechanism in Rails to trigger interactions. They deal with web concerns: http, sessions, cookies, params, mime types, responses, etc.
        * That should be all they do. Once the web concerns are dealt with, they should delegate the further behavior to an interaction.
        * They are organized by contexts that are aligned with app stakeholder roles and/or departments.
        * Example files:
            * translation <- Each context has its own folder
                * translation_jobs_controller.rb
        * When namespaces or controller names refer to ActiveRecord models always use plural form. (this is standard rails naming convention)
        * They inherit from ApplicationController.
        * They check permissions (via pundit policies).
        * If they delegate to an interaction, we don't use strong params. That's handled in the interaction.
    * helpers
        * Provide methods to render certain UI elements or content.
        * They are organized by contexts, just like controllers and views.
        * To avoid naming conflicts, method names contain namespace in method name.
        * Example methods:
            * pm/workflow_steps_helper.rb => pm_workflow_steps_completion_icon(@workflow_step)
    * interactions
        * Interactions model application behavior.
        * They are organized by contexts, just like controllers.
        * They inherit from ApplicationInteraction (ActiveInteraction::Base).
        * They use the ActiveInteraction gem.
        * They receive the same arguments as the corresponding controller action would expect as params. That makes it easy to invoke an Interaction from a controller action: Just forward the params as is. Just basic ruby data types of hashes, arrays, strings, numbers, etc.
            * :id - at root level to find the record.
            * model attributes are specified at the top level so that the interaction object responds to the same attributes as the AR model. This allows using the interaction instance as a form object.
        * All attributes of the wrapped AR model are exposed as direct inputs on the interaction so that the interaction can be used as form object for Rails forms.
        * To consider: isolate additional arguments under `:non_ar_attrs` hash in inputs to make update and create easy: `inputs.except(:non_ar_attrs)`.
        * They validate, restrict, and coerce their input args using ActiveInteraction mechanisms. That means we don't need strong params.
        * Their names start with a verb.
        * Error handling: Prefer validity over raising exceptions. Use `errors.add` and `errors.merge!`. When passing input arguments and there is a chance that something can go wrong, call `.run` instead of `.run!`. Otherwise calling `.run!` is fine.
        * Validations: Go on the ActiveRecord model by default. Move them to interactions only if they are specific to the interaction.
        * For complex input coercion and validation scenarios consider using dry-validation in a `before_type_check` callback.
        * Composition: ActiveInteraction has a `#compose` method. TODO: Investigate what advantages it provides over calling nested interactions manually.
        * `#to_model`: Add this method to #create (`::Job.new`) and #update (`::Job.find(id)`) interactions.
        * Delegating display methods to underlying object: 
            * Use `attr_reader :<wrapped_object>` and `delegate :display_name, to: :<wrapped_object>, prefix: false`
        * Optional inputs and nil: When updating a model's attribute we need to handle the following cases:
            * attr not given, so leave DB column as is (check via attr? predicate)
            * attr given: Update DB column with new value
          It appears that attr? returns true for an empty string (""), so if you e.g., want to check if a state machine trigger event was selected, you have to use `attr.present?` rather than `attr?`.
          ActiveInteraction can handle this via the `#given?` predicate. (https://github.com/AaronLasseigne/active_interaction#optional-inputs)
        * When referring to ActiveRecord models in the class name or namespace, use plural form. This is to avoid naming conflicts with ActiveRecord models.
        * Rails nested attributes: Require special treatment. See the following classes in RtUi for an example:
            * Pm::WorkflowStepActionsController
            * Pm::WorkflowStepActions::Update
        * See [ActiveInteraction docs](https://github.com/AaronLasseigne/active_interaction#rails) for how to integrate them into controllers and forms.
        * infrastructure
            * We house this under the `interactions` folder so that the "infrastructure" part of the namespace doesn't get lost.
            * Makes underlying technology available to the app. All infrastructure services live in this folder.
            * Organized/grouped from a provider perspective. Services are aligned with underlying technology.
            * These wrap service providers so that if we swap out a service provider we have a single place to change code.
            * Examples:
                * google_places_api.rb
                * facebook_authentication_api.rb
        * Example files:
            * pm
                * workflow_steps
                    * create.rb
    * lib
        * Contains files that are custom to ClearCove Software Inc., however they are not specific to this application.
        * Example: `ApplicationInteraction < ActiveInteraction::Base`
    * mailers (nothing special here)
    * models
        * Models describe the application's data structures and relations.
        * Are dumb ActiveRecord objects. They are concerned with ORM, associations, model level validations, scopes, attribute readers.
        * Are organized by database tables, relationships, composition and inheritance.
        * Don't nest AR models! This causes namespace issues with policies, interactions, helpers, etc. (Note: It's ok to nest policies and interactions inside context modules, however not in AR classes). Note: It's ok to nest POROs inside AR models.
        * Never use context namespacing for models! I've had lots of trouble with autoloading.
        * What's in a model:
            * filterrific spec
            * active record associations
            * scopes
            * validations
            * delegations
            * state machines
            * attribute reader methods.
                * Naming: prefix attributes used for display with "display_", e.g. "display_name", "display_full_name".
                    * Display methods on self always start with `display_`.
                    * When delegating to another object's display method, we prefix with the object as we would with Rails' delegate method: `user_display_name` delegates to user#display_name.
                * Don't produce html markup (use view helpers for that)
                * Examples:
                    * .id_options_for_select (where the prefix is the name of the attribute to be selected, typically id)
                    * .type_options_for_select
                    * .user_id_options_for_select
                    * #display_name
                    * #assigned_to_display_name
                    * #display_current_progress
                    * #language_display_name
                    * #display_status
                * Possibly replace `display_` with `decorated_` prefix.
            * Simple before_callbacks, e.g., to downcase and strip whitespace around email addresses.
        * What's _NOT_ in a model:
            * after_callbacks (use interactions instead!)
            * mutating/process methods (use interactions instead!)
        * Contracts are also stored under models since they are concerned with data. We use dry-validation to specify validation rules for data structures.
            * Use in controller: 
                * https://mensfeld.pl/2017/03/dry-validation-as-a-schema-validation-layer-for-ruby-on-rails-api/
            * Use in controller and model:
                * http://gafur.me/2017/11/13/refactoring-rails-application-with-dry-validation.html
            * validates :contract_compliance: Checks attrs against one or more contracts.
    * policies
        * Determine what a user is allowed to do.
        * We use [pundit](https://github.com/varvet/pundit) to specify policies.
        * [Pundit best practices](https://crypt.codemancers.com/posts/2018-07-29-leveraging-pundit/)
        * Policies look at user identity, roles, and a data status.
        * Use them in views like so: `- if policy([:pm, @job]).show?`
        * Use them in controllers like so: `authorize([:pm, @job_step])`
        * Use them as scopes like so:
          `@jobs = policy_scope([:pm, ::Job.filterrific_find(@filterrific).page(params[:page])])`
        * Organized by contexts and singular model names. IMPORTANT: Don't nest policies for nested AR models (maybe a hint that we shouldn't nest AR models!)
        * Each context can have a `Base` policy that model specific policies in the context will inherit from.
        * TODO: Decide if policies should live under the `interactions` folder instead of under `policies` folder. They are concerned with behavior after all! Note that contracts are stored under `models`, so it would make sense to store policies under `interactions`.
    * serializers
        * Used to consistently serialize data, e.g., into jsonb columns. Will symbolize all keys.
        * postgres_jsonb_array_serializer.rb
        * postgres_jsonb_serializer.rb
    * views
        * Are organized by contexts, same as controllers.
        * HTML views
            * We prefer HAML over ERB since it requires much less code to be typed. Makes for faster reading of view files.
            * We use Bootstrap4 as UI library.
            * Forms:
                * bootstrap_form gem
                    * Prefer `display_form_errors(f)` over `f.alert_message`
                * nested/dynamic forms: 
                    * cocoon gem
                    * alternative: https://www.pluralsight.com/guides/ruby-on-rails-nested-attributes
        * JSON views
            * We go by [JSON:API](https://jsonapi.org/) spec.
            * We use JSON builder to build the views.
    * workers
        * We use Sidekiq for background job processing. We use the Sidekiq native api, rather than ActiveJob since some of Sidekiq's advanced features are not available via AJ.
        * Workers are organized in contexts, just like controllers, interactions, views. Pluralize model names.

#### Layered architecture:

* UI/Interfaces
    * routes
    * views
    * controllers
    * API endpoints
    * view helpers
    * background jobs/workers
    * tests
* Domain model / business logic
    * interactions (behavior)
    * models (data)
* Infrastructure
    * gems
    * integrations
    * db
    * redis
    * file storage

Dependencies can only go downwards, never upwards.

#### Rails nested form helpers

This article has good info and usable code for nested forms, a la cocoon: https://www.pluralsight.com/guides/ruby-on-rails-nested-attributes

#### Testing

?

#### Client side code

* re-frame
* react-bootstrap

### Turbolinks and Stimulus

* Good presentation about both at https://www.youtube.com/watch?v=UucTtozapTE
    * Load more (infinite scroll) at 18'16", [code](https://github.com/pascallaliberte/stimulus-turbolinks-demo/)
    * select2 and Turbolinks at 21'01", [code](https://github.com/pascallaliberte/stimulus-turbolinks-select2/)
* use webpack and Ecmascript 6

