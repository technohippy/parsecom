# Parsecom

Yet-Another Parse.com Library written in Pure Ruby

**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [Parsecom](#parsecom)
  - [Usage](#usage)
    - [Preparing](#preparing)
    - [Declaring Parse Classes](#declaring-parse-classes)
    - [Objects](#objects)
      - [Creating Objects](#creating-objects)
      - [Retrieving Objects](#retrieving-objects)
      - [Updating Objects](#updating-objects)
        - [Counters](#counters)
        - [Arrays](#arrays)
        - [Relations](#relations)
      - [Deleting Objects](#deleting-objects)
      - [Batch Operations](#batch-operations)
    - [Queries](#queries)
      - [Basic Queries](#basic-queries)
      - [Query Constraints](#query-constraints)
      - [Queries on Array Values](#queries-on-array-values)
      - [Relational Queries](#relational-queries)
      - [Counting Objects](#counting-objects)
      - [Compound Queries](#compound-queries)
    - [Users](#users)
      - [Sign up](#sign-up)
      - [Log in](#log-in)
      - [Requesting A Password Reset](#requesting-a-password-reset)
      - [Retrieving Users](#retrieving-users)
      - [Updating Users](#updating-users)
      - [Querying](#querying)
      - [Deleting Users](#deleting-users)
      - [Linking Users](#linking-users)
    - [Roles](#roles)
      - [Creating Roles](#creating-roles)
      - [Retrieving Roles](#retrieving-roles)
      - [Updating Roles](#updating-roles)
      - [Deleting Roles](#deleting-roles)
    - [Files](#files)
      - [Uploading Files](#uploading-files)
      - [Associating with Objects](#associating-with-objects)
      - [Deleting Files](#deleting-files)
    - [Cloud Functions](#cloud-functions)
    - [Security](#security)

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

### Objects

#### Creating Objects

To create new parse object, just new and save the object.

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

#### Retrieving Objects

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

To fetch a child object, you can use the :include parameter.

```ruby
results = GameScore.find :where => {:objectId => 'Ed1nuqPvcm'}, :include => 'game'
```

To know more about retrieving objects, see spec/parse_query_spec.rb

#### Updating Objects

To update attributes, just update the attribute and save.

```ruby
game_score = GameScore.find_by_id 'Ed1nuqPvcm'
game_score.score = 73453
game_score.save
```

If you want to update attributes without retrieving the object, you can use
the Parse::Client object for it.

```ruby
Parse::Client.default.update :GaemScore, 'Ed1nuqPvcm', :score => 73453
```

##### Counters

```ruby
game_score = GameScore.find_by_id 'Ed1nuqPvcm'
game_score.score = Parse::Op::Increment.new 1
game_score.save
```

##### Arrays

```ruby
game_score = GameScore.find_by_id 'Ed1nuqPvcm'
game_score.skils = Parse::Op::AddUnique.new 'flying', 'kungfu'
game_score.save
```

##### Relations

```ruby
game_score = GameScore.find_by_id 'Ed1nuqPvcm'
game_score.opponents = Parse::Op::AddRelation.new player.pointer
game_score.save
```

```ruby
game_score = GameScore.find_by_id 'Ed1nuqPvcm'
game_score.opponents = Parse::Op::RemoveRelation.new player.pointer
game_score.save
```

#### Deleting Objects

```ruby
game_score = GameScore.find_by_id 'Ed1nuqPvcm'
game_score.delete
```

```ruby
game_score = GameScore.find_by_id 'Ed1nuqPvcm'
game_score.opponents = Parse::Op::Delete.new
game_score.save
```

#### Batch Operations

```ruby
seans_score = GameScore.new 'score' => 1337, 'playerName' => 'Sean Plott'
zerocools_score = GameScore.new 'score' => 1338, 'playerName' => 'ZeroCool'
batch = Parse::Batch.new
batch.add_request do
  seans_score.save
  zerocools_score.save
end
result = batch.run
```

### Queries

#### Basic Queries

```ruby
game_scores = GameScore.find :all
```

#### Query Constraints

```ruby
game_scores = GameScore.find :where => {"playerName" => "Sean Plott", "cheatMode" => false}
```

```ruby
game_scores = GameScore.find :where => proc {
  column(:score).gte(1000).lte(3000)
}
```

```ruby
game_scores = GameScore.find :where => proc {
  column(:score).in(1, 3, 5, 7, 9)
}
```

```ruby
game_scores = GameScore.find :where => proc {
  column(:playerName).nin("Jonathan Walsh", "Dario Wunsch", "Shawn Simon")
}
```

```ruby
game_scores = GameScore.find :where => proc {
  column(:score).exists
}
```

```ruby
game_scores = GameScore.find :where => proc {
  column(:score).exists(false)
}
```

```ruby
game_scores = GameScore.find :where => proc {
  subquery = subquery_for :Team
  subquery.where {column(:winPct).gt(0.5)}
  subquery.key = 'city'
  column(:hometown).select(subquery)
}
```

```ruby
game_scores = GameScore.find :order => 'score'
```

```ruby
game_scores = GameScore.find :order => '-score'
game_scores = GameScore.find :order_desc => 'score'
```

```ruby
game_scores = GameScore.find :order => ['score', '-name']
```

```ruby
game_scores = GameScore.find :limit => 200, :skip => 400
```

```ruby
game_scores = GameScore.find :keys => ['score', 'playerName']
```

#### Queries on Array Values

```ruby
game_scores = GameScore.find :where => proc {
  column(:arrayKey).contains(2)
}
```

```ruby
game_scores = GameScore.find :where => proc {
  column(:arrayKey).all(2, 3, 4)
}
```

#### Relational Queries

```ruby
game_scores = GameScore.find :where => proc {
  post = Parse::Object(:Post).new :objectId => '8TOXdXf3tz'
  column(:post).eq(post)
}
```

```ruby
game_scores = GameScore.find :where => proc {
  subquery = subquery_for :Post
  subquery.where do
    column(:image).exists(true)
  end
  column(:post).in_query(subquery)
}
```

```ruby
game_scores = GameScore.find :where => proc {
  pointer = Parse::Pointer.new('className' => 'Post', 'objectId' => '8TOXdXf3tz')
  related_to :likes, pointer
}
```

#### Counting Objects

TBD

#### Compound Queries

```ruby
game_scores = GameScore.find :where => proc {
  or_condition column(:wins).gt(150), column(:wins).lt(5)
}
```

### Users

#### Sign up

```ruby
user = Parse::User.sign_up 'YOUR USERNAME', 'YOUR PASSWORD'
```

#### Log in

```ruby
user = Parse::User.log_in 'YOUR USERNAME', 'YOUR PASSWORD'
```

#### Requesting A Password Reset

```ruby
Parse::User.request_password_reset 'your@email.address'
```

#### Retrieving Users

```ruby
user = Parse::User.find_by_id :g7y9tkhB7O
```

#### Updating Users

```ruby
user = Parse::User.find_by_id :g7y9tkhB7O
user.phone = '415-369-6201'
user.save
```

#### Querying

```ruby
users = Parse::User.find :all
```

#### Deleting Users

```ruby
user = Parse::User.find_by_id :g7y9tkhB7O
user.delete
```

#### Linking Users

TBD

### Roles

#### Creating Roles

```ruby
moderator = Parse::Role.new 'name' => 'Moderators', 'ACL' => Parse::ACL::PUBLIC_READ_ONLY
moderator.save
```

```ruby
moderator = Parse::Role.new 'name' => 'Moderators', 'ACL' => Parse::ACL::PUBLIC_READ_ONLY
moderator.roles.add Parse::Role.new('objectId' => 'Ed1nuqPvc')
moderator.users.add Parse::User.new('objectId' => '8TOXdXf3tz')
moderator.save
```

#### Retrieving Roles

```ruby
role = Parse::Role.find_by_id 'mrmBZvsErB'
role.name # => 'Moderators'
role.ACL.readable? '*' # => true
role.ACL.writable? 'role:Administrators' # => true
```

#### Updating Roles

```ruby
user1 = Parse::User.new 'objectId' => '8TOXdXf3tz'
user2 = Parse::User.new 'objectId' => 'g7y9tkhB7O'
role = Parse::Role.find_by_id 'mrmBZvsErB'
role.users = Parse::Op::AddRelation.new user1.pointer, user2.pointer
role.save
```

```ruby
removed_role = Parse::Role.new 'objectId' => 'Ed1nuqPvc'
role = Parse::Role.find_by_id 'mrmBZvsErB'
role.roles = Parse::Op::RemoveRelation.new removed_role.pointer
role.save
```

#### Deleting Roles

```ruby
role = Parse::Role.find_by_id 'mrmBZvsErB'
role.delete
```

### Files

#### Uploading Files

```ruby
file = Parse::File.new :name => 'hello.txt', :content => 'Hello, World!'
file.save
file.url # => "http://files.parse.com/7883...223/7480...b6d-hello.txt"
```

```ruby
file = Parse::File.new :name => 'myPicture.jpg', :content => './myPicture.jpg'
file.save
file.url # => "http://files.parse.com/7883...223/81c7...bdf-myPicture.jpg"
```

#### Associating with Objects 

```ruby
file = Parse::File.new :name => 'profile.png', :content => './profile.png'
profile = PlayerProfile.new 'name' => 'Andrew', 'picture' => file
profile.save
```

#### Deleting Files

```ruby
file.delete!
```

### Analytics

TBD

### Push Notifications

TBD

### Installations

#### Uploading Installation Data

```ruby
installation = Parse::Installation.new :deviceType => 'ios', :deviceToken => '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', :channels => ['']
installation.save
```

#### Retrieving Installations

```ruby
installation = Parse::Installation.find_by_id :mrmBZvsErB
```

#### Updating Installations

```ruby
installation = Parse::Installation.find_by_id :mrmBZvsErB
installation.channels = ['', 'foo']
installation.save
```

#### Querying Installations

```ruby
installations = Parse::Installation.find! :all
```

#### Deleting Installations

```ruby
installation = Parse::Installation.find_by_id :mrmBZvsErB
installation.delete!
```

### Cloud Functions

```ruby
client = Parse::Client.new
client.hello
```

### GeoPoints

TBD

### Security

If you add an exclamation mark, "!" after the method name, the method is executed by using the master key.

```ruby
class_a = ClassA.new :columnA => 'Hello, parse.com'
class_a.save!
```
