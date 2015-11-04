# Radical

A change in API definition.

## A quick demo

We want to setup an API that serves a single user object with a few
attributes and a friends list.

First we start by defining our database, which for this demo will
be a global hash.

``` ruby
$database = { users: { 1 => { name: 'Luke', age: 25, friend_ids: [2] },
                       2 => { name: 'Fred', age: 30, friend_ids: [] } } }
```

So apart from Luke liking Fred but Fred not liking Luke this is so
far so straightforward.

Next we're going to define a little schema.

``` ruby
require 'radical'

$database = { users: { 1 => { name: 'Luke', age: 25, friend_ids: [2] },
                       2 => { name: 'Fred', age: 30, friend_ids: [] } } }

module Schema
  User = Radical::Typed::Hash[name: String,
                              age: Integer,
                              friend_ids: Radical::Typed::Array[Integer]]
end
```

Hopefully this still seems fairly self explanatory. Well you might
be a little upset with the idea of typing in ruby. Just go with it
a minute for my sake.

Next we want to serve our API.

``` ruby
require 'radical'

$database = { users: { 1 => { name: 'Luke', age: 25, friend_ids: [2] },
                       2 => { name: 'Fred', age: 30, friend_ids: [] } } }

module Schema
  User = Radical::Typed::Hash[name: String,
                              age: Integer,
                              friend_ids: Radical::Typed::Array[Integer]]
end

Radical::Route[:user, Radical::Arg[id: Integer], Schema::User].define do
  def get(id)
    $database[:users][id]
  end
end

run Radical::Application.new
```

Save this file as `config.ru`. Now provided you have `rack` and `radical`
gems installed you should be able to now boot your API. If you haven't
add a `Gemfile` alongside your API file and add both dependencies to it.

Now run `rackup` and visit http://localhost:9292?route[user.1].
