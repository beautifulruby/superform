RSpec.describe Superform::NamespaceCollection do
  subject(:collection) do
    described_class.new(:bars, parent: namespace) do |collection|
      collection.field(:baz)
    end
  end

  let(:namespace) { Superform::Namespace.root(:foo, object: object) }
  let(:object) do
    OpenStruct.new(
      bars: [
        OpenStruct.new(baz: "A"),
        OpenStruct.new(baz: "B")
      ]
    )
  end

  describe "each" do
    it "creates an indexed namespace for each item" do
      object.bars.each.with_index do |bar, index|
        expect(Superform::Namespace).to receive(:new).with(
          index, factory: a_kind_of(Superform::Factory), parent: collection, object: bar
        ).ordered
      end

      collection.each.to_a
    end

    it "yields a namespace for each collection item" do
      expect { |b| collection.each(&b) }.to yield_successive_args(
        an_object_satisfying { |item| item.is_a?(Superform::Namespace) && item.key == 0 },
        an_object_satisfying { |item| item.is_a?(Superform::Namespace) && item.key == 1 }
      )
    end

    context "with a namespace using another factory" do
      let(:factory) { Superform::Rails::Factory.new }
      let(:namespace) do
        Superform::Namespace.root(:foo, object:, factory:)
      end

      it "creates an indexed namespace for each item" do
        object.bars.each.with_index do |bar, index|
          expect(Superform::Namespace).to receive(:new).with(
            index, factory:, parent: collection, object: bar
          ).ordered
        end

        collection.each.to_a
      end
    end
  end

  describe "#assign" do
    it "assigns the value to each namespace" do
      collection.assign([{ baz: "C" },{ baz: "D" }])
      expect(collection.serialize).to eq([{ baz: "C" },{ baz: "D" }])
    end
  end
end
