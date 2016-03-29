#
# Cookbook: consul_template
# License: MIT
#
# Copyright 2016, Vision Critical Inc.
#
require 'poise'

module ConsulTemplateCookbook
  module Resource
    # A `consul_template_installation` resource for managing the installation of
    # consul-template.
    # @action create
    # @action remove
    # @since 0.1.0
    class ConsulTemplateInstallation < Chef::Resource
      include Poise(inversion: true)
      provides(:consul_template_installation)
      actions(:create, :remove)
      default_action(:create)

      # @!attribute version
      # The version of consul-template to install.
      # @return [String]
      attribute(:version, kind_of: String, name_attribute: true)

      def consul_template_program
        @program ||= provider_for_action(:consul_template_program).consul_template_program
      end
    end
  end
end
