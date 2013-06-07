## ActiveRecord Teradata Adapter for JRuby

Are you using JRuby? ActiveRecord?  Teradata?  This is for you.

This is a driver that lets you use Teradata with ActiveRecord.

### Usage

In your `Gemfile` add

    gem 'activerecord-jdbcteradata-driver'

In `database.yml` add something like
 
    development:
      adapter: teradata
      username: user
      password: pass
      host: hostname
      database: DBC
      pool: 25
      wait_timeout: 5
      tmode: TERA

### License

MIT.  Free for you to use any way you want.

### Force lowercase attributes

Ruby people like lowercase attribute names.  If you have a table that
has upper case column names, you can force ActiveRecord to use lowercase
attribute names.

For example, if this:

    user = User.new
    user.first_name = "John"

looks better than:

    user = User.name
    user.FIRST_NAME = "John"

you can set:

    ActiveRecord::ConnectionAdapters::TeradataAdapter.lowercase_schema_reflection = true

in config/initializers

### Building the code

A small part of the code is written in java.  You are going to want to
run:

    ruby java_compile.rb

### Running tests

    bundle exec rspec spec

I am also testing against the activerecord test suite.

### Questions?

Post a message in the issues list.  I am happy to respond.

### Patches?

Fork.  Do a pull request.  Thanks.

### Thanks for you contribution

Evgeny Rahman

* support for <> NULL, != NULL, and = NULL support, as suggested by his
  colleague Tim Chevalier
* Downcase support.  See #force_downcase_attributes
* COP mode support
* Support for users in the issues list


