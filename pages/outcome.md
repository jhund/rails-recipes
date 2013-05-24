---
layout: default
nav_id: outcome
---

<div class="page-header">
  {% include site_navigation.html %}
  <h2>Outcome.rb</h2>
</div>

In multi-step operations, you want to be able to provide meaningful feedback
to your users if something goes sideways.

Outcome is a great way to shuttle the outcome of a process from the processing
method back to the user. An Outcome instance has the following attributes:

* success: [Boolean] whether process was successful or not.
* result: [Object] the return value of the process.
* messages: [Array<String>] an array of messages.

How to use it in your app
-------------------------

In this example we use a PurchaseTransaction Service Object to handle a user's
purchase in our online store. Processing a purchase is a fairly complex process
that involves several other ActiveRecord models, as well as API calls to 3rd
party services. A lot that can go wrong.

So we wrap the entire process into a method and call that single method from
our controller. The @outcome instance will contain detailed messaging if something
went wrong, and how to fix it.

```ruby
# app/controllers/purchase_transactions_controller.rb
class PurchaseTransactionsController < ApplicationController

  ...

  def create
    @outcome = PurchaseTransaction.create(params[:purchase])

    respond_to do |format|
      format.html {
        if @outcome.success?
          # Everything went well, display messages as flash notice
          flash[:notice] = @outcome.messages_to_html
          # redirect to new purchase
          redirect_to purchase_path(@outcome.result)
        else
          # Something didn't work. Display messages as flash warning
          flash[:alert] = @outcome.messages_to_html
          # re-render the form
          @purchase = @outcome.result
          render :action => 'new'
        end
      }
    end
  end

  ...

end
```

```ruby
# app/models/purchase_transaction.rb
class PurchaseTransaction

  # Creates a new purchase
  def self.create(params)
    # initialize outcome attrs
    l_success = true
    l_messages = []
    # initialize AR model
    new_purchase = Purchase.build(params)
    # ... more complex processing:
    l_outcome = make_api_request_for_product_type(new_product.product_type)
    if l_outcome.success?
      # ... do more processing on success
      l_messages += l_outcome.messages
      new_purchase.save
    else
      # stop processing, set success flag and collect error messages.
      l_success = false
      l_messages += l_outcome.messages
    end
    # Return an instance of Outcome
    Outcome.new(l_success, new_purchase, l_messages)
  end

end
```

Show me the code
----------------

This is all there is to the Outcome.rb class:

```ruby
{% include code/outcome.rb %}
```


### Credits

This library is inspired by
[Mutations](https://github.com/cypriss/mutations/blob/master/lib/mutations/outcome.rb).
