module Superform
  module Rails
    module Components
      module Concerns
        module Requirable
          def field_attributes
            super.merge(validation_attributes)
          end

          def validation_attributes
            return {} unless presence_validated?
            { required: true }
          end

          def presence_validated?
            object = field.parent&.object
            return false unless object&.class&.respond_to?(:validators_on)
            object.class.validators_on(field.key).any? { |v| v.kind == :presence }
          end
        end
      end
    end
  end
end
