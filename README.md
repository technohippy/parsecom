# Parsecom

Yet-Another Parse.com Library written in Pure Ruby

## Usage

### Preparing

Before using the library, you should import this and set your credentials on 
the library.

```ruby
require 'parsecom'
Parse.credentials :application_id => 'YOUR APPID', :api_key => 'YOUR APIKEY'
```

If you have some plan to use the master_key, please set it.

```ruby
Parse.credentials :application_id => 'YOUR APPID', :api_key => 'YOUR APIKEY', 
  :master_key => 'YOUR MASTER KEY'
```

If you do not want to write your credentials on your code directly,
please set environment variables:

    export PARSE_APPLICATION_ID="<YOUR_APPLICATION_ID>"
    export PARSE_API_KEY="<YOUR_API_KEY>"
    export PARSE_MASTER_KEY="<YOUR_MASTER_KEY>"

### Declaring Parse Classes

There are three ways to declare a parse class.

First, you can declare a ruby class inherited from Parse::Object. By using
this way, you can add your own properties and methods to the class.

```ruby
class GameScore < Parse::Object
  # ..snip..
end
```

Secondly, you can also declare your parse class by calling the Parse::Object 
method. 

```ruby
Parse::Object(:GameScore)
```

It returns a parse class, so that you can call its class methods directly.

```ruby
Parse::Object(:GameScore).find :limit => 3
```

Lastly, Parse::Object class provides create method for you to declare new
class.

```ruby
Parse::Object.create :GameScore
```

It may be suitable for writing code in declarative style.

### Creating Objects

To create new parse object, juse new and save the object.

```ruby
game_score = GameScore.new
game_score.score = 1337
game_score.playerName = 'Sean Plott'
game_score.cheatMode = false
game_score.new? # => true
game_score.save
game_score.new? # => false
game_score.parse_object_id # => 'Ed1nuqPvcm'
```

### Retrieving Objects

There are two ways to retrieve objects. One is using Query objects directly and
another is using Parse::Object as a facade of a query object.

```ruby
# useing Query object directly
query = Parse::Query.new GameScore
query.where :objectId => 'Ed1nuqPvcm'
results = query.run

# using Query object through Parse::Object
results = GameScore.find :where => {:objectId => 'Ed1nuqPvcm'}
# if you would like to find by objectId, you can easily pass it directly
result = GameScore.find_by_id 'Ed1nuqPvcm'
```

More complex query

```ruby
# useing Query object directly
results = Parse::Query.new(GameScore).
  limit(10).
  order(score).
  where do
    column(:score).gte(1000).lte(3000)
    column(:cheatMode).eq(false)
  end.
  invoke

# using Query object through Parse::Object
results = GameScore.find :limit => 10, :order => 'score', 
  :where => proc{
    column(:score).gte(1000).lte(3000)
    column(:cheatMode).eq(false)
  }
```

To know more about retrieving objects, see spec/parse_query_spec.rb

### Updating Objects

To update attributes, just update the attribute and save.

```ruby
result = GameScore.find_by_id 'Ed1nuqPvcm'
result.score = 73453
result.save
```

If you want to update attributes without retrieving the object, you can use
the Parse::Client object for it.

```ruby
Parse::Client.default.update :GaemScore, 'Ed1nuqPvcm', :score => 73453
```

#### Counters

```ruby
result = GameScore.find_by_id 'Ed1nuqPvcm'
result.score = Parse::Op::Increment.new 1
result.save
```

#### Arrays

```ruby
result = GameScore.find_by_id 'Ed1nuqPvcm'
result.skils = Parse::Op::AddUnique.new 'flying', 'kungfu'
result.save
```

#### Relations

```ruby
result = GameScore.find_by_id 'Ed1nuqPvcm'
result.opponents = Parse::Op::AddRelation.new player.pointer
result.save
```

```ruby
result = GameScore.find_by_id 'Ed1nuqPvcm'
result.opponents = Parse::Op::RemoveRelation.new player.pointer
result.save
```

### Deleting Objects

```ruby
result = GameScore.find_by_id 'Ed1nuqPvcm'
result.delete
```

```ruby
result = GameScore.find_by_id 'Ed1nuqPvcm'
result.opponents = Parse::Op::Delete.new
result.save
```

### Sign up

```ruby
user = Parse::User.sign_up 'YOUR USERNAME', 'YOUR PASSWORD'
```

### Log in

```ruby
user = Parse::User.log_in 'YOUR USERNAME', 'YOUR PASSWORD'
```

### Security

If you add an exclamation mark, "!" after the method name, the method is executed by using the master key.

```ruby
class_a = ClassA.new :columnA => 'Hello, parse.com'
class_a.save!
```
