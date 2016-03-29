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
    # A `consul_template` resource for creating consul templates
    # files.
    # @action create
    # @provides consul_template
    # @since 0.1.0
    class ConsulTemplate < Chef::Resource
      include Poise(fused: true)
      include ::ConsulTemplateCookbook::Helpers
      provides(:consul_template)
      actions(:create, :remove)
      default_action(:create)

      # @!attribute name
      # The name of the Consul Template configuration file
      # @return [String]
      attribute(:name, kind_of: String, regex: /\A\w+\.json\z/, name_attribute: true)
      # exposes source, cookbook, content, options attributes
      attribute('', template: true)
      # @!attribute conf_dir
      # The path to the configuration directory on disk.
      # @return [String]
      attribute(:conf_dir, kind_of: String, default: lazy { node['consul_template']['config']['conf_dir'] })
      # @!attribute conf_dir
      # The path to the template directory on disk.
      # @return [String]
      attribute(:template_dir, kind_of: String, default: lazy { node['consul_template']['config']['template_dir'] })
      # @!attribute owner
      # The consul-template template file owner.
      # @return [String]
      attribute(:owner, kind_of: String, default: lazy { node['consul_template']['service']['user'] })
      # @!attribute group
      # The consul-template template file group.
      # @return [String]
      attribute(:group, kind_of: String, default: lazy { node['consul_template']['service']['group'] })
      # @!attribute destination
      # The file that will be rendered from the source.
      # @return [String]
      attribute(:destination, kind_of: String, required: true)
      # @!attribute command
      # The command to run whenever the template is updated.
      # @return [String]
      attribute(:command, kind_of: String)
      # @!attribute command_timeout
      # The timeout (e.g. 1s,1m,1h) for the command.
      # @return [String]
      attribute(:command_timeout, kind_of: String)
      # @!attribute perms
      # The permissions to set.
      # @return [Fixnum]
      attribute(:perms, kind_of: String)
      # @!attribute backup
      # Toggles whether or not to backup the destination before rendering.
      # @return [FalseClass, TrueClass]
      attribute(:backup, kind_of: [FalseClass, TrueClass])

      def conf_file
        node.join_path(conf_dir, name)
      end

      def template_file
        file = source.nil? ? name : source
        node.join_path(template_dir, file.partition('.').first.concat('.ctmpl'))
      end

      def config_options
        %i(destination command command_timeout perms backup)
      end

      # Transforms the options for this resource into JSON
      # which is interchangeable with HashiCorp Configuration Language (HCL)
      # @see https://github.com/hashicorp/hcl
      def to_json
        config = to_hash.keep_if do |k, _|
          config_options.include?(k.to_sym)
        end
        config[:source] = template_file
        JSON.pretty_generate({ template: config.sort.to_h }, quirks_mode: true)
      end

      action(:create) do
        notifying_block do
          file new_resource.conf_file do
            content new_resource.to_json
            unless node.windows?
              owner new_resource.owner
              group new_resource.group
              mode '0440'
            end
          end

          file new_resource.template_file do
            content new_resource.content
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
          file new_resource.conf_file do
            action :delete
          end

          file new_resource.template_file do
            action :delete
          end
        end
      end
    end
  end
end
