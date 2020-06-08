# frozen_string_literal: true

module Wgclient
  module Gen
    class Parser
      class << self
        def perform(peer:)
          peer_conf = fill_client_data(template_file, peer)
          peer_conf = fill_server_data(peer_conf)
          peer_conf
        end

        def fill_client_data(peer_conf, peer)
          peer_conf = peer_conf.gsub(/@client_private_key/, peer.private_key)
          peer_conf = peer_conf.gsub(/@client_ip_address/, peer.ip_address)
          peer_conf
        end

        def fill_server_data(peer_conf)
          peer_conf = peer_conf.gsub(/@server_public_key/, Wgclient::Config.server_public_key)
          peer_conf = peer_conf.gsub(/@server_endpoint/, Wgclient::Config.server_endpoint)
          peer_conf = peer_conf.gsub(/@server_public_key/, Wgclient::Config.server_public_key)
          peer_conf = peer_conf.gsub(/@dns/, Wgclient::Config.dns)
          peer_conf
        end

        def template_path
          File.join(File.dirname(File.expand_path(__dir__)), '../config/peer.conf.template')
        end

        def template_file
          File.read(template_path)
        end
      end
    end
  end
end
