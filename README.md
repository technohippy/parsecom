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
    - [Analytics](#analytics)
      - [App-Open Analytics](#app-open-analytics)
      - [Custom Analytics](#custom-analytics)
    - [Installations](#installations)
      - [Uploading Installation Data](#uploading-installation-data)
      - [Retrieving Installations](#retrieving-installations)
      - [Updating Installations](#updating-installations)
      - [Querying Installations](#querying-installations)
      - [Deleting Installations](#deleting-installations)
    - [Cloud Functions](#cloud-functions)
    - [GeoPoints](#geopoints)
      - [GeoPoint](#geopoint)
      - [Geo Queries](#geo-queries)
    - [Security](#security)
    - [Debug](#debug)

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

Or

```ruby
seans_score = GameScore.new 'score' => 1337, 'playerName' => 'Sean Plott'
zerocools_score = GameScore.new 'score' => 1338, 'playerName' => 'ZeroCool'
Parse.batch do
  seans_score.save
  zerocools_score.save
end
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
  column(:score).between(1000..3000)
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

```ruby
game_score_count = GameScore.count 'playerName' => 'Jonathan Walsh'
```

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
file = Parse::ParseFile.new :name => 'hello.txt', :content => 'Hello, World!'
file.save
file.url # => "http://files.parse.com/7883...223/7480...b6d-hello.txt"
```

```ruby
file = Parse::ParseFile.new :name => 'myPicture.jpg', :content => './myPicture.jpg'
file.save
file.url # => "http://files.parse.com/7883...223/81c7...bdf-myPicture.jpg"
```

#### Associating with Objects 

```ruby
file = Parse::ParseFile.new :name => 'profile.png', :content => './profile.png'
profile = PlayerProfile.new 'name' => 'Andrew', 'picture' => file
profile.save
```

#### Deleting Files

```ruby
file.delete!
```

### Analytics

#### App-Open Analytics

```ruby
app_opened_event = Parse::Event::AppOpened.new :at => '2013-10-18T20:53:25Z'
app_opened_event.fire
```

```ruby
Parse::Event::AppOpened.fire :at => '2013-10-18T20:53:25Z'
```

#### Custom Analytics

```ruby
Parse::Event.create :Search
search_event = Search.new :at => '2013-10-18T20:53:25Z', 
  :priceRange => "1000-1500", :source => "craigslist", :dayType => "weekday"
search_event.fire
```

```ruby
error_event = Parse::Event::Error.new :at => '2013-10-18T20:53:25Z', :code => 404
error_event.fire
```

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

#### GeoPoint

```ruby
geo_point = Parse::GeoPoint.new :latitude => 40.0, :longitude => -30.0
place = PlaceObject.new :location => geo_point
```

#### Geo Queries

```ruby
place = PlaceObject.find :limit => 10, :where => proc {
  geo_point = Parse::GeoPoint.new :latitude => 30.0, :longitude => -20.0
  column(:location).near_sphere geop_point
}
```

```ruby
places = PlaceObject.find :limit => 10, :where => proc {
  geo_point = Parse::GeoPoint.new :latitude => 30.0, :longitude => -20.0
  column(:location).near_sphere(geo_point).max_distance_in_miles(10.0)
}
```

```ruby
places = PizzaPlaceObject.find :limit => 10, :where => proc {
  southwest = Parse::GeoPoint.new :latitude => 37.71, :longitude => -122.53
  northeast = Parse::GeoPoint.new :latitude => 30.82, :longitude => -122.37
  column(:location).within(southwest, northeast)
}
```

### Security

If you add an exclamation mark, "!" after the method name, the method is executed by using the master key.

```ruby
class_a = ClassA.new :columnA => 'Hello, parse.com'
class_a.save!
```

If you want to use the master key for all API calls, set the use_master_key flag true so that you don't need to add "!" for all methods.

```ruby
Parse.use_master_key!
```

### Debug

To see debug output, set $DEBUG true.

```ruby
$DEBUG = true
Post.find :all
```

You can see something like the following in $stderr.

```
opening connection to api.parse.com...
opened
<- "GET /1/classes/Post? HTTP/1.1\r\nX-Parse-Application-Id: abcdefghijklmnopqrstuvwxyz0123456789ABCD\r\nContent-Type: application/json\r\nAccept: application/json\r\nUser-Agent: A parse.com client for ruby\r\nX-Parse-Rest-Api-Key: abcdefghijklmnopqrstuvwxyz0123456789ABCD\r\nHost: api.parse.com\r\n\r\n"
-> "HTTP/1.1 200 OK\r\n"
-> "Access-Control-Allow-Origin: *\r\n"
-> "Access-Control-Request-Method: *\r\n"
-> "Cache-Control: max-age=0, private, must-revalidate\r\n"
-> "Content-Type: application/json; charset=utf-8\r\n"
-> "Date: Sun, 08 Dec 2013 08:14:40 GMT\r\n"
-> "ETag: \"abcdefghijklmnopqrstuvwxyz012345\"\r\n"
-> "Server: nginx/1.4.2\r\n"
-> "Set-Cookie: _parse_session=abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789; domain=.parse.com; path=/; expires=Tue, 07-Jan-2014 08:14:40 GMT; secure; HttpOnly\r\n"
-> "Status: 200 OK\r\n"
-> "X-Runtime: 0.116322\r\n"
-> "X-UA-Compatible: IE=Edge,chrome=1\r\n"
-> "Content-Length: 603\r\n"
-> "Connection: keep-alive\r\n"
-> "\r\n"
reading 603 bytes...
-> "{\"results\":[{\"author\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"xWJVfYPbBP\"},\"body\":\"\xE6\x9C\xAC\xE6\x96\x87\",\"title\":\"\xE3\x82\xBF\xE3\x82\xA4\xE3\x83\x88
\xE3\x83\xAB\",\"comments\":{\"__type\":\"Relation\",\"className\":\"Comment\"},\"createdAt\":\"2013-10-29T15:06:45.872Z\",\"updatedAt\":\"2013-10-29T15:09:01.111Z\",\"objectId\":\"6EyX2aypgD\"
},{\"comments\":{\"__type\":\"Relation\",\"className\":\"Comment\"},\"createdAt\":\"2013-10-30T04:38:47.068Z\",\"updatedAt\":\"2013-10-30T04:38:47.068Z\",\"objectId\":\"njvHr4aelZ\"},{\"comment
s\":{\"__type\":\"Relation\",\"className\":\"Comment\"},\"createdAt\":\"2013-10-30T04:40:37.397Z\",\"updatedAt\":\"2013-10-30T04:40:37.397Z\",\"objectId\":\"EDdGtur3vY\"}]}"
read 603 bytes
Conn keep-alive
```

Also you can do dry-run.

```ruby
Parse.dry_run!
Post.find :all
```

This does not call any API and shows something like the following in $stderr.

```
get /1/classes/Post?
X-Parse-Application-Id: abcdefghijklmnopqrstuvwxyz0123456789ABCD
Content-Type: application/json
Accept: application/json
User-Agent: A parse.com client for ruby
X-Parse-REST-API-Key: abcdefghijklmnopqrstuvwxyz0123456789ABCD

```
