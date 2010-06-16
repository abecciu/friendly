
module Friendly
  class Attribute
    class << self
      def register_type(type, sql_type, serializabler = nil, &block)
        sql_types[type.name] = sql_type
        converters[type]     = block
        serializablers[type] = serializabler if serializabler
      end

      def deregister_type(type)
        sql_types.delete(type.name)
        converters.delete(type)
      end

      def sql_type(type)
        sql_types[type.name]
      end

      def sql_types
        @sql_types ||= {}
      end

      def converters
        @converters ||= {}
      end

      def serializablers
        @serializablers ||= {}
      end

      def custom_type?(klass)
        !sql_type(klass).nil?
      end
    end

    converters[Integer] = lambda { |s| s.to_i }
    converters[String]  = lambda { |s| s.to_s }

    attr_reader :klass, :name, :type, :default_value

    def initialize(klass, name, type, options = {})
      @klass         = klass
      @name          = name
      @type          = type
      @default_value = options[:default]
      build_accessors
    end

    def typecast(value)
      !type || value.is_a?(type) ? value : convert(value)
    end

    def to_serializable(value)
      return value if value.nil?

      if serializablers[type].nil?
        value
      else
        serializablers[type].call(value)
      end
    end

    def convert(value)
      assert_converter_exists(value)
      converters[type].call(value)
    end

    def default
      if !default_value.nil?
        default_value
      elsif type.respond_to?(:new)
        type.new
      else
        nil
      end
    end

    def assign_default_value(document)
      document.send(:"#{name}=", default)
    end

    protected
      def build_accessors
        n = name
        klass.class_eval do
          attr_reader n, :"#{n}_was"

          eval <<-__END__
            def #{n}=(value)
              will_change(:#{n})
              @#{n} = self.class.attributes[:#{n}].typecast(value)
            end

            def #{n}_serializable
              self.class.attributes[:#{n}].to_serializable(#{n})
            end

            def #{n}_changed?
              attribute_changed?(:#{n})
            end
          __END__
        end
      end

      def assert_converter_exists(value)
        unless converters.has_key?(type)
          msg = "Can't convert #{value} to #{type}. 
                 Add a custom converter to Friendly::Attribute::CONVERTERS."
          raise NoConverterExists, msg
        end
      end

      def converters
        self.class.converters
      end

      def serializablers
        self.class.serializablers
      end
  end
end
