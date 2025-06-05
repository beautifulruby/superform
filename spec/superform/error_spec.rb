RSpec.describe Superform::Error do

  describe Superform::DuplicateNameError do
    it { expect(described_class.new).to be_a(Superform::Error)  }
  end

  describe Superform::InvalidNodeError do
    it { expect(described_class.new).to be_a(Superform::Error)  }
  end
end
