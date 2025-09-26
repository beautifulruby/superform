# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superform::Rails::Form::Field do
  let(:user) { User.new(email: "test@example.com", first_name: "John") }
  let(:form) { Superform::Rails::Form.new(user) }
  let(:field) { form.field(:email) }

  describe "HTML5 input convenience methods" do
    it { expect(field.text.type).to eq("text") }
    it { expect(field.hidden.type).to eq("hidden") }
    it { expect(field.password.type).to eq("password") }
    it { expect(field.email.type).to eq("email") }
    it { expect(field.url.type).to eq("url") }
    it { expect(field.tel.type).to eq("tel") }
    it { expect(field.phone.type).to eq("tel") }
    it { expect(field.number.type).to eq("number") }
    it { expect(field.range.type).to eq("range") }
    it { expect(field.date.type).to eq("date") }
    it { expect(field.time.type).to eq("time") }
    it { expect(field.datetime.type).to eq("datetime-local") }
    it { expect(field.month.type).to eq("month") }
    it { expect(field.week.type).to eq("week") }
    it { expect(field.color.type).to eq("color") }
    it { expect(field.search.type).to eq("search") }
    it { expect(field.file.type).to eq("file") }
    it { expect(field.radio("male").type).to eq("radio") }
  end

  describe "Rails compatibility aliases" do
    describe "#check_box" do
      it "creates checkbox component" do
        component = field.check_box
        expect(component).to be_a(Superform::Rails::Components::Checkbox)
      end
    end

    describe "#text_area" do
      it "creates textarea component" do
        component = field.text_area
        expect(component).to be_a(Superform::Rails::Components::Textarea)
      end
    end
  end

  describe "argument forwarding" do
    it "passes through all attributes correctly" do
      component = field.email(class: "form-input", required: true, placeholder: "Enter email")
      expect(component.type).to eq("email")
    end

    it "allows type override with input method" do
      component = field.input(type: :search, class: "form-input")
      expect(component.type).to eq("search")
    end

    it "handles radio button value parameter correctly" do
      component = field.radio("female", class: "radio-input", data: { value: "f" })
      expect(component.type).to eq("radio")
    end
  end

  describe "HTML5 client-side validations" do
    context "input" do
      it "adds required when presence validation exists" do
        component = field.input
        expect(component.field_attributes[:required]).to eq(true)
      end

      it "does not add required when no presence validation" do
        component = form.field(:last_name).input
        expect(component.field_attributes.key?(:required)).to eq(false)
      end

      it "allows required: false to override" do
        component = field.input(required: false)
        attrs = component.send(:attributes)
        expect(attrs[:required]).to eq(false)
      end
    end

    context "checkbox" do
      it "adds required when presence validation exists" do
        component = field.checkbox
        expect(component.field_attributes[:required]).to eq(true)
      end

      it "does not add required when no presence validation" do
        component = form.field(:last_name).checkbox
        expect(component.field_attributes.key?(:required)).to eq(false)
      end

      it "allows required: false to override" do
        component = field.checkbox(required: false)
        attrs = component.send(:attributes)
        expect(attrs[:required]).to eq(false)
      end
    end

    context "textarea" do
      it "adds required when presence validation exists" do
        component = field.textarea
        expect(component.field_attributes[:required]).to eq(true)
      end

      it "does not add required when no presence validation" do
        component = form.field(:last_name).textarea
        expect(component.field_attributes.key?(:required)).to eq(false)
      end

      it "allows required: false to override" do
        component = field.textarea(required: false)
        attrs = component.send(:attributes)
        expect(attrs[:required]).to eq(false)
      end
    end

    context "select" do
      it "adds required when presence validation exists" do
        component = field.select("a", "b")
        expect(component.field_attributes[:required]).to eq(true)
      end

      it "does not add required when no presence validation" do
        component = form.field(:last_name).select("a", "b")
        expect(component.field_attributes.key?(:required)).to eq(false)
      end

      it "allows required: false to override" do
        component = field.select("a", "b", required: false)
        attrs = component.send(:attributes)
        expect(attrs[:required]).to eq(false)
      end
    end
  end
end
