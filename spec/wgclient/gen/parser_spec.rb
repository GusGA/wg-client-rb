# frozen_string_literal: true

RSpec.describe Wgclient::Gen::Parser do
  let(:config_file_path) { File.join(File.dirname(File.expand_path(__FILE__)), '/fixtures/wg_config.json') }
  let(:peer_config_file) do
    File.read(File.join(File.dirname(File.expand_path(__FILE__)), '/fixtures/test_device_name.conf'))
  end
  let(:peer) do
    OpenStruct.new({ public_key: 'public_key',
                     private_key: 'private_key',
                     ip_address: '10.0.0.1/32',
                     device_name: 'test device name' })
  end
  before do
    allow(Wgclient::Config).to receive(:file_path).and_return(config_file_path)
  end

  describe '.perform' do
    it { expect(described_class.perform(peer: peer)).to eq(peer_config_file) }
  end
end
