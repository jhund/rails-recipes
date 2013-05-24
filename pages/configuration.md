---
layout: default
nav_id: configuration
---

<div class="page-header">
  {% include site_navigation.html %}
  <h2>Configuration</h2>
</div>

Every Rails app requires some kind of configuration:

* Rails Secret Token
* Database connection params
* 3rd party API keys
* Exception notification recipients
* ...

Most of these should never be tracked in source control. So what do you do?

Store all configuration in environment variables. This approach works universally:

* no matter where you host: dedicated, VPS, heroku, AWS, ...
* in all runtime modes: production, development and test.
* single server apps or large clusters.

So instead of hardcoding your database connection params in `config/database.yml`
you pull them in via ERB and ENV vars like so:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: <%= ENV['POSTGRES_DATABSE'] %>
  pool:     <%= ENV['POSTGRES_POOLSIZE'] %>
  username: <%= ENV['POSTGRES_USERNAME'] %>
  password: <%= ENV['POSTGRES_PASSWORD'] %>
```

The [Figaro gem](https://github.com/laserlemon/figaro) is a great tool to manage your config:

* Install the gem: `gem 'figaro'`
* `rails generate figaro:install` - this will add a file `config/application.yml`
  which is ignored by git.
* add all your configuration parameters to `config/application.yml`.
* when your app boots up, all required ENV vars will be initialized.
* when you deploy to heroku, all ENV vars will be initialized there.

Here is an example for `config/application.yml`:

```yaml
# Figaro application configuration
development:
  YOUR_APP_SECRET_TOKEN: 'haksdjfhalksdjfh60b84e71e...'
  POSTGRES_DATABASE: your_app_development
  POSTGRES_PASSWORD: pg_password
  POSTGRES_POOLSIZE: 5
  POSTGRES_USERNAME: pg_user_name
  REDIS_HOST: '127.0.0.1'
  REDIS_PORT: 6379
  TWITTER_CONSUMER_KEY: dfg345KJH...
  TWITTER_CONSUMER_SECRET: ZPFe78ku...

production:
  ...

test:
  ...
```

