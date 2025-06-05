RSpec.describe Superform::Node do
  subject(:node) { described_class.new('name', parent: nil) }

  it { expect(node.key).to eq 'name' }
  it { expect(node.parent).to be_nil }

  context 'with a parent' do
    subject(:node) { described_class.new('child', parent: parent) }

    let(:parent) { Superform::Namespace.root('root') }

    it { expect(node.parent).to eq parent }
  end
end
