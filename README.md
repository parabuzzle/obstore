ObStore
===

[![Build Status](https://travis-ci.org/parabuzzle/obstore.svg)](https://travis-ci.org/parabuzzle/obstore) [![Coverage Status](https://coveralls.io/repos/parabuzzle/obstore/badge.png?branch=master)](https://coveralls.io/r/parabuzzle/obstore?branch=master) [![Gem Version](https://badge.fury.io/rb/obstore.svg)](http://badge.fury.io/rb/obstore)

ObStore is a smart persistent Object store.

ObStore allows you to save any object to a persistent storage system (such as a file) along with metadata about that object that you can recall later using a different process or thread. You can also set an expiry for an object and ObStore will lazily delete the data for you. ObStore is thread safe and multi-process safe.

# Installation

Add it to your gemfile
```
gem 'obstore'
```

Install using bundler
```
bundle install
```

or install manually
```
gem install obstore
```

# Usage
Using ObStore is simple.

## Basic Usage
You can use ObStore to save objects to a local file for use later or by other apps

### Create a storage object

```
require 'obstore'

# Create an obstore object
@obstore = ObStore::FileStore.new :database => './obstore.db'

# If your system supports atomic writes, you can (and should) turn that on
@obstore.atomic_writes = true

# Or alternatively when you create the obstore object
ObStore::FileStore.new :database=> './obstore.db', :atomic_writes=>true
```
### Save and Retrieve objects
```
# save any object you want to persist using the save method
# -> note: the key must be a symbol or you will receive a TypeError
@obstore.store :metrics,  {:stat1=>123, :stat2=>456}     # pass it a key and a value
@obstore.store :anything, "can be any object you like"   # the key can be as simple as a string
@obstore.store :custom,   MyCustomObject                 # the key can even be an instance of an object

# retrieve the object
metrics  = @obstore.fetch :metrics    #=> {:stat1=>123, :stat2=>456}
anything = @obstore.fetch :anything   #=> "can be any object you like"
custom   = @obstore.fetch :custom     #=> MyCustomObject
```

## More Advanced Concepts

### Obstore allows you to use dot syntaxing
sort of like the way ActiveRecord works
```
@obstore.metrics.fetch  #=> {:stat1=>123, :stat2=>456}

# note - without calling fetch, you will get the underlying ObStore::Data object
@obstore.metrics        #=> ObStore::Data
```

### Keys that Expire
ObStore will check if your data is expired and clean the db on fetch for you (lazy expiry)
```
@obstore.store :metrics, {:stat1=>123, :stat2=>456}, {:expiry=>10} #expiry is seconds
@obstore.fetch :metrics  #=> {:stat1=>123, :stat2=>456}
sleep 11
@obstore.fetch :metrics #=> nil
```

### Metadata for your object (dimensions)
ObStore supports adding as much metadata as you like about the object you are saving.
That data saved to the ObStore::Data object when saved to the ObStore db
```
@obstore.store :metrics, {:stat1=>123, :stat2=>456}, {:expiry=>10, :metadata=>{:extra=>"foo"}}
metrics = @obstore.metrics
metrics.extra  #=> "foo"
metrics.more = "more metadata"
metrics.more   #=> "more metadata"
# don't forget to store your changes
@obstore.metrics = metrics
```

### Clean all Expired keys
ObStore can remove all expired data at once (run this in a cronjob?)
```
@obstore.compact!
```

# Contributing
 * fork the repository
 * create a feature branch
 * add your awesome code
 * send a pull request
 * have a beer

# Test Status
 * ruby-1.9.3
 * ruby-2.0.0
 * ruby-2.1.2
 * jruby-1.7.11

# TODO
 * Redis Support in Place of FileStore as a choice
 * Abstract Storage Provider
 * Make the code less clever...

# License
The MIT License (MIT)

Copyright (c) 2014 Michael Heijmans

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
