module Superform
  # Extracted responsibility for creating the right nodes
  class Factory

    def build(key, type, **, &)
      case type
      when :namespace
        Namespace.new(key, factory: self, **, &)
      when :collection
        NamespaceCollection.new(key, factory: self, **, &)
      when :field
        field_class.new(key, **, &)
      else
        raise InvalidNodeError, "unsupported node: #{type}"
      end
    end

    private

      # Avoid lexical order problem when subclassing this Factory class,
      # to lookup custom Field subclasses within their namespace.
      def field_class
        module_name = self.class.name.split("::")[0..-2].join("::")
        namespace = Object.const_get(module_name)

        if namespace.const_defined?(:Field)
          namespace::Field
        else
          Superform::Field
        end
      end

  end
end
