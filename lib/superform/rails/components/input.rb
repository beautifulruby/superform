module Superform
  module Rails
    module Components
      class Input < Field
        prepend Concerns::Requirable

        def view_template(&)
          input(**attributes)
        end

        def field_attributes
          {
            id: dom.id,
            name: dom.name,
            type: type,
            value: value
          }
        end

        def has_client_provided_value?
          case type.to_s
          when "file", "image"
            true
          else
            false
          end
        end

        def value
          dom.value unless has_client_provided_value?
        end

        def type
          @type ||= ActiveSupport::StringInquirer.new(attribute_type || value_type)
        end

        protected
          def value_type
            case field.value
            when URI
              "url"
            when Integer, Float
              "number"
            when Date, DateTime
              "date"
            when Time
              "time"
            else
              "text"
            end
          end

          def attribute_type
            if type = @attributes[:type] || @attributes["type"]
              type.to_s
            end
          end
      end
    end
  end
end
