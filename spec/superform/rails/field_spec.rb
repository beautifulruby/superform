RSpec.describe Superform::Rails::Field do
  subject(:field) { described_class.new(:bar_baz, parent:) }

  let(:parent) { Superform::Namespace.root(:foo) }

  it { expect(field).to be_a(Superform::Field) }

  describe 'title' do
    it 'titleizes the key' do
      expect(field.title).to eq 'Bar Baz'
    end
  end

  describe 'button' do
    it { expect(field.button).to be_a(Superform::Rails::Components::ButtonComponent) }
  end

  describe 'input' do
    it { expect(field.input).to be_a(Superform::Rails::Components::InputComponent) }
  end

  describe 'checkbox' do
    it { expect(field.checkbox).to be_a(Superform::Rails::Components::CheckboxComponent) }
  end

  describe 'label' do
    it { expect(field.label).to be_a(Superform::Rails::Components::LabelComponent) }
  end

  describe 'textarea' do
    it { expect(field.textarea).to be_a(Superform::Rails::Components::TextareaComponent) }
  end

  describe 'select' do
    it { expect(field.select).to be_a(Superform::Rails::Components::SelectField) }
  end
end
