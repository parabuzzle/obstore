# Provides the wrapper for pstore
#
# Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
# Copyright:: Copyright (c) 2014 Michael Heijmans
# License::   MIT

require 'pstore'
require 'yaml'
require 'obstore/data'

module ObStore
  class FileStore

    attr_accessor :_store

    def initialize(opts={})
      opts[:database] ||= "./tmp/obstore.db"
      opts[:threadsafe] ||= true
      opts[:atomic_writes] ||= false
      @_store = PStore.new(opts[:database], opts[:threadsafe])
      @_store.ultra_safe = opts[:atomic_writes]
    end

    # removes stale records from the pstore db
    def compact!
      keys = []
      @_store.transaction do
        keys = @_store.roots
      end
      keys.each do |key|
        fetch_data_by_key key.to_sym # just fetching the stale items deletes them
      end
      return true
    end

    # stores data to pstore db
    def store(key, value, opts={})
      if key.class != Symbol
        raise TypeError "key must be of type symbol"
      end
      store_data_by_key key, value, opts
    end

    # stores data to pstore db
    def store!(key, value, opts={})
      if key.class != Symbol
        raise TypeError "key must be of type symbol"
      end
      return true if store_data_by_key key, value, opts
    end

    # fetches saved object for the given key
    def fetch(key)
      if key.class != Symbol
        raise TypeError "key must be of type symbol"
      end
      data = fetch_data_by_key(key)
      if data.nil?
        return nil
      else
        return data.fetch
      end
    end

    # lists all the keys that are currently in the DBs
    def keys
      @_store.transaction do
        @_store.roots
      end
    end

    # returns boolean if atomic writes is active
    def atomic_writes
      @_store.ultra_safe
    end

    # sets atomic writes
    def atomic_writes=(bool)
      @_store.ultra_safe = bool
    end

    private

    # marshals the data object to a string
    def marshal(obj)
      YAML.dump obj
    end

    # un-marshals the passed string into an object
    def unmarshal(str)
      if str.nil?
        return nil
      end
      YAML.load str
    end

    # internal method used for storing data by key
    def store_data_by_key(key, *args)
      options = {}
      if args.class == Array
        value = args.shift
        options = args.shift
      else
        value = args
      end
      @_store.transaction do
        if value.class == ObStore::Data
          @_store[key.to_sym] = marshal value
        elsif value.nil?
          @_store.delete key.to_sym
        else
          @_store[key.to_sym] = marshal ObStore::Data.new(value, options)
        end
        @_store.commit
      end
      return value
    end

    def store_obj_by_key(key, args)
      if args.class != ObStore::Data
        unless args.class == NilClass
          raise TypeError "data must be of type ObStore::Data"
        end
      end
      store_data_by_key key, args
    end

    # method used by method_missing to fetch data
    def fetch_data_by_key(key)
      @_store.transaction do
        data = unmarshal(@_store[key.to_sym])
        if data.nil?
          return data
        end
        if data.stale?
          data = nil
          @_store.delete key.to_sym
          @_store.commit
        end
        return data
      end
    end

    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^(.+)=$/
        store_obj_by_key($1, *args)
      elsif meth.to_s =~ /^(.+)$/
        fetch_data_by_key($1)
      else
        super
      end
    end

  end
end
