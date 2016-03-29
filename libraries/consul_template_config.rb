#
# Cookbook: consul_template
# License: MIT
#
# Copyright 2016, Vision Critical Inc.
#
require 'poise'
require_relative './helpers'

module ConsulTemplateCookbook
  module Resource
    # A `consul_template_config` resource for managing consul-template's configuration
    # files.
    # @action create
    # @provides consul_template_config
    # @since 0.1.0
    class ConsulTemplateConfig < Chef::Resource
      include Poise(fused: true)
      include ::ConsulTemplateCookbook::Helpers
      provides(:consul_template_config)
      actions(:create, :remove)
      default_action(:create)

      # @!attribute conf_dir
      # The path to the configuration directory on disk.
      # @return [String]
      attribute(:conf_dir, kind_of: String, default: lazy { node['consul_template']['config']['conf_dir'] })
      # @!attribute conf_dir
      # The path to the template directory on disk.
      # @return [String]
      attribute(:template_dir, kind_of: String, default: lazy { node['consul_template']['config']['template_dir'] })
      # @!attribute owner
      # The consul-template configuration file owner.
      # @return [String]
      attribute(:owner, kind_of: String, default: lazy { node['consul_template']['service']['user'] })
      # @!attribute group
      # The consul-template configuration file group.
      # @return [String]
      attribute(:group, kind_of: String, default: lazy { node['consul_template']['service']['group'] })

      # @see https://github.com/hashicorp/consul-template#options
      attribute(:options, option_collector: true, default: lazy { node['consul_template']['config']['options'] })

      # Transforms the option attribute for this resource into JSON
      # which is interchangeable with HashiCorp Configuration Language (HCL)
      # @see https://github.com/hashicorp/hcl
      def to_json
        JSON.pretty_generate(options, quirks_mode: true)
      end

      def config_directories
        [conf_dir, template_dir]
      end

      action(:create) do
        notifying_block do
          new_resource.config_directories.each do |dir|
            directory dir do
              recursive true
              unless node.windows?
                owner new_resource.owner
                group new_resource.group
                mode '0750'
              end
            end
          end

          file node.join_path(new_resource.conf_dir, 'main.json') do
            content new_resource.to_json
            unless node.windows?
              owner new_resource.owner
              group new_resource.group
              mode '0440'
            end
          end
        end
      end

      action(:remove) do
        notifying_block do
          file node.join_path(new_resource.conf_dir, 'main.json') do
            action :delete
          end
        end
      end
    end
  end
end
