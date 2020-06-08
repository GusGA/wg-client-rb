# frozen_string_literal: true

require 'json'

module Wgclient
  class Config
    FILE_KEYS = %i[server_public_key server_endpoint network_ip network_last_ip peers dns].freeze

    def self.write_config_file
      Dir.mkdir(File.expand_path('~/.wg-client')) unless Dir.exist?(File.expand_path('~/.wg-client'))
      config_file
      save_content(true)
    end

    def self.file_path(non_template = false)
      config_file_path = File.join(File.expand_path('~/.wg-client/wg.json'))
      return config_file_path if non_template

      config_file_template_path = File.join(File.dirname(File.expand_path(__FILE__)), '../config/wg.json')
      File.exist?(config_file_path) ? config_file_path : config_file_template_path
    end

    def self.config_file
      @config_file ||= JSON.parse(File.read(file_path), symbolize_names: true)
    end

    def self.add_new(peer)
      valid_config_file?
      peers_list = peers || []
      new_peers_list = peers_list + [peer.to_h]
      @config_file[:peers] = new_peers_list
      save_content
    end

    def self.save_content(non_template = false)
      File.open(file_path(non_template), 'w') { |file| file.write(JSON.pretty_generate(@config_file)) }
      @config_file = nil
      config_file
    end

    def self.valid_config_file?(minimum = false)
      validation_keys = FILE_KEYS
      validation_keys = %i[network_ip dns network_last_ip] if minimum
      validation_keys.map { |key| !@config_file[key].empty? }.all?
    end

    FILE_KEYS.each do |key|
      define_singleton_method key do
        config_file[key]
      end
    end
  end
end
