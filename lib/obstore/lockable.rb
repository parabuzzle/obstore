# Provides semaphore support to an object
#
# Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
# Copyright:: Copyright (c) 2014 Michael Heijmans
# License::   MIT

require 'thread'

module ObStore
  module Lockable

    def mutex
      @mutex ||= Mutex.new
    end

    def with_mutex
      mutex.synchronize { yield }
    end

  end
end