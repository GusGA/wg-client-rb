# frozen_string_literal: true

RSpec.describe Wgclient::WireGuard do
  let(:wg_bin_path) { './spec/wireguard_bin/wg' }

  before do
    allow(described_class).to receive(:wb_bin_path).and_return(wg_bin_path)
  end

  it { expect(described_class.installed?).to eq(true) }

  describe '.generate_private_key' do
    let(:private_key) { described_class.generate_private_key }

    it { expect(private_key.size).to eq(44) }
    it { expect(private_key[-1]).to eq('=') }
  end

  describe '.generate_public_key' do
    let(:private_key) { described_class.generate_private_key }
    let(:public_key) { described_class.generate_public_key(private_key: private_key) }

    it { expect(public_key.size).to eq(44) }
    it { expect(public_key[-1]).to eq('=') }
  end
end
