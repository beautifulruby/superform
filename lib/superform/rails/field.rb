module Superform
  module Rails
    # The Field class is designed to be extended to create custom forms.
    # Override the methods in the subclass to use your custom component classes.
    class Field < Superform::Field
      def button(**attributes)
        Components::ButtonComponent.new(self, attributes:)
      end

      def input(**attributes)
        Components::InputComponent.new(self, attributes:)
      end

      def checkbox(**attributes)
        Components::CheckboxComponent.new(self, attributes:)
      end

      def label(**attributes, &)
        Components::LabelComponent.new(self, attributes:, &)
      end

      def textarea(**attributes)
        Components::TextareaComponent.new(self, attributes:)
      end

      def select(*collection, **attributes, &)
        Components::SelectField.new(self, attributes:, collection:, &)
      end

      def title
        key.to_s.titleize
      end
    end
  end
end
