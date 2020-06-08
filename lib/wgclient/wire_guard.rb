# frozen_string_literal: true

# Wireguard bin class handler
module Wgclient
  class WireGuard
    class Error < StandardError; end
    class ExecNotFound < StandardError; end
    class NoKeyError < StandardError; end
    class << self
      def installed?
        raise ExecNotFound, 'WireGuard not installed, please install to continue' if wb_bin_path.empty?

        true
      end

      def generate_private_key
        `#{wb_bin_path} genkey`.chomp if installed?
      end

      def generate_public_key(private_key:)
        raise NoKeyError, 'Please pass a valid public key' if private_key.nil?

        `#{wb_bin_path} pubkey <<< "#{private_key}"`.chomp
      end

      def create_peer(public_key:, ip_address:)
        `#{wb_bin_path} set #{interface} peer #{public_key} allowed-ips #{ip_address}`
      end

      def remove_peer(public_key:)
        `#{wb_bin_path} set #{interface} peer #{public_key} remove`
      end

      def save_configuration
        `wg-quick save #{interface}`
      end

      private

      def interface
        Wgclient::Config.server_interface
      end

      def wb_bin_path
        @wb_bin_path ||= `which wg`.chomp
      end
    end
  end
end
