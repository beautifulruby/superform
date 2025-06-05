RSpec.describe Superform::Factory do
  subject(:factory) { described_class.new }

  describe "build" do
    let(:parent) { Superform(:user, object: 1) }

    it { expect(factory.build(:ord, :namespace, parent: nil)).to be_a(Superform::Namespace) }
    it { expect(factory.build(:ord, :collection, parent:)).to be_a(Superform::NamespaceCollection) }
    it { expect(factory.build(:ord, :field, parent:)).to be_a(Superform::Field) }

    context 'when the node type is not mapped to a symbol' do
      it { expect { factory.build(:type, :wrong) }.to raise_error Superform::InvalidNodeError }
    end
  end
end
