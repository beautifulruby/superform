RSpec.describe Superform::Rails::Factory do
  subject(:factory) { described_class.new }

  describe 'build' do
    let(:parent) { Superform::Namespace.root(:foo)}
    it { expect(factory.build(:bar, :field, parent:)).to be_a(Superform::Rails::Field) }
  end
end
