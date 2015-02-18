# This provides the data object that obstore uses to save your data
# and retrieve your data with metadata
#
# Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
# Copyright:: Copyright (c) 2014 Michael Heijmans
# License::   MIT

require 'yaml'
require 'obstore/lockable'

module ObStore
  class Data

    include ObStore::Lockable

    attr_accessor :expiry
    attr_reader :updated, :data

    def initialize(data=nil, options={})
      @expiry = options[:expiry] # in seconds
      @data = {}
      store_data_by_key :data, data
      @updated = Time.now
      if options[:metadata]
        options[:metadata].each do |key, value|
          store_data_by_key key, value
        end
      end
    end

    # returns the object you had saved
    def fetch
      fetch_data_by_key(:data)
    end

    # returns boolean value if data has expired
    def stale?
      if @expiry
        if ts < Time.now.to_i - @expiry
          return true
        end
      end
      return false
    end

    # Saves the object
    def save(data)
      self.data=data
    end

    # custom setter for data attribute that sets the update time
    def data=(data)
      store_data_by_key(:data, data)
    end

    # custom getter for retrieving data from the data hash
    def data
      fetch_data_by_key(:data)
    end

    # helper method to return the timestamp as an int
    def ts
      with_mutex { @updated.to_i }
    end

    private

    # method used by method_missing to store meta data
    def store_data_by_key(key, value)
      with_mutex {
        @data.store key.to_sym, value
        @updated = Time.now
      }
    end

    # method used by method_missing to fetch meta data
    def fetch_data_by_key(key)
      with_mutex { @data[key.to_sym] }
    end

    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^(.+)=$/
        store_data_by_key($1, *args)
      elsif meth.to_s =~ /^(.+)$/
        fetch_data_by_key($1)
      else
        super
      end
    end

  end
end
