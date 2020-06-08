# frozen_string_literal: true

require 'wgclient/gen/version'
require 'wgclient/gen/peer_builder'
require 'wgclient/gen/parser'
require 'wgclient/wire_guard'
require 'wgclient/config'

module Wgclient
  module Gen
    class Error < StandardError; end
    class << self
      def create_peer(device_name:)
        peer = Wgclient::Gen::PeerBuilder.build_peer(device_name: device_name)
        begin
          Wgclient::WireGuard.create_peer(public_key: peer.public_key, ip_address: peer.ip_address)
          peer_config_file = Wgclient::Gen::Parser.perform(peer: peer)
          write_config_file(peer_config_file)
          Wgclient::WireGuard.save_configuration
        rescue Excpetion => e
          puts e
          exit(1)
        end
      end

      def remove_peer(public_key:)
        Wgclient::WireGuard.remove_peer(public_key: public_key)
      rescue Excpetion => e
        puts e
        exit(1)
      end

      def write_config_file(config_file, peer)
        File.write(peer_conf_file_name(peer), config_file)
      end

      def peer_conf_file_name(peer)
        peer.device_name.split(' ').map(&:downcase).join('_') + '.conf'
      end
    end
  end
end
