module Superform
  module Rails
    module Components
      class Checkbox < Field
        prepend Concerns::Requirable

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
    end
  end
end
