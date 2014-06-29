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

    attr_accessor :store

    def initialize(opts={})
      opts[:database] ||= "./tmp/obstore.db"
      opts[:threadsafe] ||= true
      opts[:atomic_writes] ||= false
      @store = PStore.new(opts[:database], opts[:threadsafe])
      @store.ultra_safe = opts[:atomic_writes]
    end

    # removes stale records from the pstore db
    def compact!
      keys = []
      @store.transaction do
        keys = @store.roots
      end
      keys.each do |key|
        fetch_data_by_key key.to_sym # just fetching the stale items deletes them
      end
      return true
    end

    private

    # marshals the data object to a string
    def marshal(obj)
      YAML.dump obj
    end

    # un-marshals the passed string into an object
    def unmarshal(str)
      YAML.load str
    end

    # method used by method_missing to store data
    def store_data_by_key(key, args)
      options = {}
      if args.class == Array
        value = args.shift
        options = args.shift
      else
        value = args
      end
      @store.transaction do
        if value.nil?
          @store.delete key.to_sym
        else
          @store[key.to_sym] = marshal ObStore::Data.new(value, options)
        end
        @store.commit
      end
    end

    # method used by method_missing to fetch data
    def fetch_data_by_key(key)
      @store.transaction do
        data = unmarshal(@store[key.to_sym])
        if data.stale?
          data = nil
          @store.delete key.to_sym
          @store.commit
        end
        return data
      end
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