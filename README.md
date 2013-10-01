# Parsecom

Yet-Another Parse.com Library written in Pure Ruby

## Usage

### Preparing

Before using the library, you should import this and set your credentials on 
the library.

    require 'parsecom'
    Parse.credentials application_id:'YOUR APPID', api_key:'YOUR APIKEY'

### Declaring Parse Classes

There are three ways to declare a parse class.

First, you can declare a ruby class inherited from Parse::Object. By using
this way, you can add your own properties and methods to the class.

    class YourParseClass < Parse::Object
      # ..snip..
    end

Secondly, you can also declare your parse class by calling the Parse::Object 
method. 

    Parse::Object(:YourParseClass)

It returns a parse class, so that you can call 

    Parse::Object(:YourParseClass).find :limit => 3

Lastly, Parse::Object class provides create method for you to declare new
class.

    Parse::Object.create :YourParseClass

It may suitable for writing code in declarative programming style.

### Creating Objects

### Retrieving Objects

