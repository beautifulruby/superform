RSpec.describe Superform::Namespace do
  subject(:parent) { described_class.root(:foo) }

  describe "#namespace" do
    it "yields a child namespace" do
      parent.namespace(:bar) do |child|
        expect(child).to be_a(described_class)
        expect(child.key).to eq(:bar)
      end
    end
  end

  describe "#field" do
    it "yields the field" do
      parent.field(:bar) do |child|
        expect(child).to be_a(Superform::Field)
        expect(child.key).to eq(:bar)
      end
    end

    context 'when adding a field under the same name' do
      it 'throws an exception about the conflicting naming' do
        expect { 2.times { parent.field(:foo) } }.to raise_error(Superform::DuplicateNameError)
      end
    end

    context 'with another factory' do
      subject(:parent) { described_class.root(:foo, factory: Superform::Rails::Factory.new) }

      it "builds a field based on the namespaced Field class" do
        parent.field(:bar) do |child|
          expect(child).to be_a(Superform::Rails::Field)
          expect(child.key).to eq(:bar)
        end
      end
    end
  end

  describe "#collection" do
    subject(:parent) { described_class.root(:foo, object:) }

    let(:object) { double("object", bar: [{ baz: "A" }]) }

    it "yields a namespace collection" do
      parent.collection(:bar) do |child|
        expect(child).to be_a(Superform::Namespace)
        expect(child.key).to eq(0)
      end
    end
  end

  describe "#serialize" do
    let(:object) { double("object", bar: "A", baz: "B") }
    it "returns the serialized representation of the fields" do
      namespace = described_class.root(:foo, object:) do |parent|
        parent.field(:bar)
        parent.field(:baz)
      end

      expect(namespace.serialize).to eq({ bar: "A", baz: "B" })
    end
  end

  describe "#each" do
    it "yields each field" do
      namespace = described_class.root(:foo) do |parent|
        parent.field(:bar)
        parent.field(:baz)
      end

      enumerator = namespace.each

      expect(enumerator.next.key).to eq(:bar)
      expect(enumerator.next.key).to eq(:baz)
    end
  end

  describe "#assign" do
    it "assigns the value to the fields" do
      namespace = described_class.root(:foo) do |parent|
        parent.field(:bar)
        parent.field(:baz)
      end

      values = { bar: "A", baz: "B" }
      namespace.assign(values)
      namespace.each do |field|
        expect(field.value).to eq(values[field.key])
      end
    end
  end
end
