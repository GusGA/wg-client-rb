# frozen_string_literal: true

require 'ostruct'

module Wgclient
  module Gen
    class PeerBuilder
      class NotSpotAvailable < StandardError; end

      def self.build_peer(device_name:)
        public_key, private_key = create_peer_keys
        ::OpenStruct.new({ private_key: private_key,
                           public_key: public_key,
                           device_name: device_name,
                           ip_address: peer_ip })
      end

      def self.create_peer_keys
        private_key = Wgclient::WireGuard.generate_private_key
        public_key = Wgclient::WireGuard.generate_public_key(private_key: private_key)
        [private_key, public_key]
      end

      def self.peers
        @peers ||= Wgclient::Config.peers
        @peers.map! { |peer| peer.transform_keys(&:to_sym) } if !@peers&.empty? && @peers&.all?
      end

      def self.peer_ip
        last_ip, mask = last_peer_ip
        octect = ip_to_octect(last_ip)
        octect[-1] = octect[-1] + 1
        raise NotSpotAvailable, 'There is not spot available on this network' unless available_spot?(octect)

        next_peer_ip = octect_to_ip(octect)
        "#{next_peer_ip}/#{mask}"
      end

      def self.last_peer_ip
        return [Wgclient::Config.network_ip.split('/')[0], '32'] unless peers&.all?

        last_peer_ip, mask = peers.last[:ip_address].split('/')
        [last_peer_ip, mask]
      end

      def self.ip_to_octect(ip)
        ip.split('.').map(&:to_i)
      end

      def self.octect_to_ip(octect)
        octect.join('.')
      end

      def self.available_spot?(octect)
        network_last_octect = ip_to_octect(Wgclient::Config.network_last_ip)
        octect.pack('CCCC').unpack1('N') <= network_last_octect.pack('CCCC').unpack1('N')
      end
    end
  end
end
