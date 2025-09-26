module Superform
  module Rails
    module Components
      class Select < Field
        prepend Concerns::Requirable

        def initialize(*, collection: [], **, &)
          super(*, **, &)
          @collection = collection
        end

        def view_template(&options)
          if block_given?
            select(**attributes, &options)
          else
            select(**attributes) { options(*@collection) }
          end
        end

        def options(*collection)
          map_options(collection).each do |key, value|
            option(selected: field.value == key, value: key) { value }
          end
        end

        def blank_option(&)
          option(selected: field.value.nil?, &)
        end

        def true_option(&)
          option(selected: field.value == true, value: true.to_s, &)
        end

        def false_option(&)
          option(selected: field.value == false, value: false.to_s, &)
        end

        protected
          def map_options(collection)
            OptionMapper.new(collection)
          end
      end
    end
  end
end
