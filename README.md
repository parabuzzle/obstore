ObStore
===

[![Build Status](https://travis-ci.org/parabuzzle/obstore.svg)](https://travis-ci.org/parabuzzle/obstore) [![Coverage Status](https://coveralls.io/repos/parabuzzle/obstore/badge.png?branch=master)](https://coveralls.io/r/parabuzzle/obstore?branch=master) [![Gem Version](https://badge.fury.io/rb/obstore.svg)](http://badge.fury.io/rb/obstore)

ObStore is a smart persistent Object store.

ObStore allows you to save any object to a file along with metadata about that object. You can also set an expiry for an object and ObStore will lazily delete the data for you.

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

### Basic Usage
You can use ObStore to save objects to a local file for use later or by other apps
```
require 'obstore'

# Create an obstore object
@obstore = ObStore::FileStore.new('./obstore.db')

# save any object you want to persist using dot syntaxing
@obstore.metrics = {:stat1=>123, :stat2=>456}
@obstore.anything = "can be set to anything"

# retrieve the object
metrics = @obstore.metrics.data     #=> {:stat1=>123, :stat2=>456}
anything = @obstore.anything.fetch  #=> "can be set to anything"
```

### Keys that Expire
ObStore will check if your data is expired and clean the db on fetch for you (lazy expiry)
```
@obstore.metrics = {:stat1=>123, :stat2=>456}, {:expiry=>10} #expiry is seconds
@obstore.metrics.data #=> {:stat1=>123, :stat2=>456}
sleep 11
@obstore.metrics #=> nil
```

### Metadata for your object (dimensions)
ObStore supports adding as much metadata as you like about the object you are saving
```
@obstore.metrics = {:stat1=>123, :stat2=>456}, {:expiry=>10, :metadata=>{:extra=>"foo"}}
@obstore.metrics.extra #=> "foo"
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
