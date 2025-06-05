module Superform
  module Rails
    # The `ApplicationComponent` is the superclass for all components in your application.
    Component = ::ApplicationComponent

    # A Phlex::HTML view module that accepts a model and sets a `Superform::Namespace`
    # with the `Object#model_name` as the key and maps the object to form fields
    # and namespaces.
    #
    # The `Form::Field` is a class that's meant to be extended so you can customize the `Form` inputs
    # to your applications needs. Defaults for the `input`, `button`, `label`, and `textarea` tags
    # are provided.
    #
    # The `Form` component also handles Rails authenticity tokens via the `authenticity_toklen_field`
    # method and the HTTP verb via the `_method_field`.
    class Form < Component
      attr_accessor :model

      delegate \
          :field,
          :collection,
          :namespace,
          :assign,
          :serialize,
        to: :@namespace

      def initialize(model, action: nil, method: nil, **attributes)
        @model = model
        @action = action
        @method = method
        @attributes = attributes
        @namespace = Namespace.root(key, object: model)
      end

      def around_template(&)
        form_tag do
          authenticity_token_field
          _method_field
          super
        end
      end

      def form_tag(&)
        form action: form_action, method: form_method, **@attributes, &
      end

      def view_template(&block)
        yield_content(&block)
      end

      def submit(value = submit_value, **attributes)
        input **attributes.merge(
          name: "commit",
          type: "submit",
          value: value
        )
      end

      def key
        @model.model_name.param_key
      end

      protected
        def authenticity_token_field
          input(
            name: "authenticity_token",
            type: "hidden",
            value: helpers.form_authenticity_token
          )
        end

        def _method_field
          input(
            name: "_method",
            type: "hidden",
            value: _method_field_value
          )
        end

        def _method_field_value
          @method || resource_method_field_value
        end

        def resource_method_field_value
          @model.persisted? ? "patch" : "post"
        end

        def submit_value
          "#{resource_action.to_s.capitalize} #{@model.model_name}"
        end

        def resource_action
          @model.persisted? ? :update : :create
        end

        def form_action
          @action ||= helpers.url_for(action: resource_action)
        end

        def form_method
          @method.to_s.downcase == "get" ? "get" : "post"
        end
    end

    module StrongParameters
      protected
        # Assigns params to the form and returns the model.
        def assign(params, to:)
          form = to
          # TODO: Figure out how to render this in a way that doesn't concat a string; just throw everything away.
          render_to_string form
          form.assign params
          form.model
        end
    end

    # Accept a collection of objects and map them to options suitable for form controls, like `select > options`
    class OptionMapper
      include Enumerable

      def initialize(collection)
        @collection = collection
      end

      def each(&options)
        @collection.each do |object|
          case object
            in ActiveRecord::Relation => relation
              active_record_relation_options_enumerable(relation).each(&options)
            in id, value
              options.call id, value
            in value
              options.call value, value.to_s
          end
        end
      end

      def active_record_relation_options_enumerable(relation)
        Enumerator.new do |collection|
          relation.each do |object|
            attributes = object.attributes
            id = attributes.delete(relation.primary_key)
            value = attributes.values.join(" ")
            collection << [ id, value ]
          end
        end
      end
    end

    module Components
      class BaseComponent < Component
        attr_reader :field, :dom

        delegate :dom, to: :field

        def initialize(field, attributes: {})
          @field = field
          @attributes = attributes
        end

        def field_attributes
          {}
        end

        def focus(value = true)
          @attributes[:autofocus] = value
          self
        end

        private

        def attributes
          field_attributes.merge(@attributes)
        end
      end

      class FieldComponent < BaseComponent
        def field_attributes
          { id: dom.id, name: dom.name }
        end
      end

      class LabelComponent < BaseComponent
        def view_template(&content)
          content ||= Proc.new { field.key.to_s.titleize }
          label(**attributes, &content)
        end

        def field_attributes
          { for: dom.id }
        end
      end

      class ButtonComponent < FieldComponent
        def view_template(&content)
          content ||= Proc.new { button_text }
          button(**attributes, &content)
        end

        def button_text
          @attributes.fetch(:value, dom.value).titleize
        end

        def field_attributes
          { id: dom.id, name: dom.name, value: dom.value }
        end
      end

      class CheckboxComponent < FieldComponent
        def view_template(&)
          # Rails has a hidden and checkbox input to deal with sending back a value
          # to the server regardless of if the input is checked or not.
          input(name: dom.name, type: :hidden, value: "0")
          # The hard coded keys need to be in here so the user can't overrite them.
          input(type: :checkbox, value: "1", **attributes)
        end

        def field_attributes
          { id: dom.id, name: dom.name, checked: field.value }
        end
      end

      class InputComponent < FieldComponent
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

      class TextareaComponent < FieldComponent
        def view_template(&content)
          content ||= Proc.new { dom.value }
          textarea(**attributes, &content)
        end
      end

      class SelectField < FieldComponent
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
