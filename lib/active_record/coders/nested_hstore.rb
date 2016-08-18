module ActiveRecord
  module Coders
    if ActiveRecord::VERSION::MAJOR < 4
      require 'activerecord-postgres-hstore'

      class NestedHstore < Hstore
        def initialize(default=nil)
          super(default)
          @nested_serializer = ::NestedHstore::Serializer.new
        end

        private

        def to_hstore obj
          super(@nested_serializer.serialize(obj))
        end

        def from_hstore hstore
          @nested_serializer.deserialize(super)
        end
      end
    elsif ActiveRecord::VERSION::MAJOR >= 4 && ActiveRecord::VERSION::MINOR >= 2
      class NestedHstore < ActiveRecord::Type::Value
        def initialize
          @nested_serializer = ::NestedHstore::Serializer.new
        end

        def type
          :hstore
        end

        def type_cast_from_user(value)
          value
        end

        def type_cast_from_database(hash)
          @nested_serializer.deserialize(hash)
        end

        def type_cast_for_database(value)
          @nested_serializer.serialize(value)
        end
      end
    else
      class NestedHstore
        def self.load(hstore)
          new.load(hstore)
        end

        def self.dump(hstore)
          new.dump(hstore)
        end

        def initialize
          @nested_serializer = ::NestedHstore::Serializer.new
        end

        def load(hash)
          @nested_serializer.deserialize(hash)
        end

        def dump(value)
          @nested_serializer.serialize(value)
        end
      end
    end
  end
end
