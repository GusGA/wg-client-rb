# frozen_string_literal: true

RSpec.describe Wgclient::Gen::PeerBuilder do
  let(:config_file_path) { File.join(File.dirname(File.expand_path(__FILE__)), '/fixtures/wg_config.json') }
  let(:last_peer) { described_class.peers[-1] }
  let(:wg_bin_path) { './spec/wireguard_bin/wg' }
  before do
    allow(Wgclient::WireGuard).to receive(:wb_bin_path).and_return(wg_bin_path)
    allow(Wgclient::Config).to receive(:file_path).and_return(config_file_path)
  end

  it { expect(described_class.peers.size).to eq(1) }

  describe '.build_peer' do
    let(:peer_instance) { described_class.build_peer(device_name: 'test device') }

    it { expect(peer_instance.ip_address).to be > last_peer[:ip_address] }
    it { expect(peer_instance.device_name).to eq('test device') }
    it { expect(peer_instance.public_key.size).to eq(44) }
    it { expect(peer_instance.public_key[-1]).to eq('=') }
    it { expect(peer_instance.private_key.size).to eq(44) }
    it { expect(peer_instance.private_key[-1]).to eq('=') }

    context 'when are not available spots on the network' do
      before do
        allow(described_class).to receive(:peers).and_return([{ ip_address: '10.0.0.254/32' }])
      end
      it { expect { peer_instance }.to raise_error(Wgclient::Gen::PeerBuilder::NotSpotAvailable) }
    end
  end
end
