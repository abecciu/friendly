require 'friendly/associations'
require 'friendly/attribute'
require 'friendly/boolean'
require 'friendly/cache'
require 'friendly/cache/by_id'
require 'friendly/data_store'
require 'friendly/document'
require 'friendly/document_table'
require 'friendly/index'
require 'friendly/indexer'
require 'friendly/memcached'
require 'friendly/query'
require 'friendly/sequel_monkey_patches'
require 'friendly/scope'
require 'friendly/scope_proxy'
require 'friendly/storage_factory'
require 'friendly/storage_proxy'
require 'friendly/translator'
require 'friendly/uuid'

require 'will_paginate/collection'

module Friendly

  class << self
    attr_accessor :datastore, :db, :cache, :serializer

    def configure(config)
      self.db        = Sequel.connect(config)
      self.datastore = DataStore.new(db)
      load_serializer(config[:serializer])
    end

    def load_serializer(serializer)
      if serializer.nil? || serializer.is_a?(String) || serializer.is_a?(Symbol)
        name = serializer.nil? ? 'json_pure' : serializer.to_s
        begin
          load File.join(File.dirname(__FILE__), 'friendly', 'serializers', "#{name}.rb")
        rescue LoadError
          raise BadSerializer, "serializer '#{name}' doesn't exist."
        end
      elsif serializer.respond_to?(:generate) && serializer.respond_to?(:parse)
        Friendly.serializer = serializer
      else
        raise BadSerializer, "serializer class should respond to parse and generate."
      end
    end

    def batch
      begin
        datastore.start_batch
        yield
        datastore.flush_batch
      ensure
        datastore.reset_batch
      end
    end

    def create_tables!
      Document.create_tables!
    end
  end

  class Error < RuntimeError; end
  class RecordNotFound < Error; end
  class MissingIndex < Error; end
  class NoConverterExists < Friendly::Error; end
  class NotSupported < Friendly::Error; end
  class BadSerializer < Friendly::Error; end

end
