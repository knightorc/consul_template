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
    # A `consul_template_installation` resource for managing the installation of
    # consul-template.
    # @action create
    # @action remove
    # @since 0.1.0
    class ConsulTemplateInstallation < Chef::Resource
      include Poise(inversion: true)
      include ::ConsulTemplateCookbook::Helpers
      provides(:consul_template_installation)
      actions(:create, :remove)
      default_action(:create)

      # @!attribute version
      # The version of consul-template to install.
      # @return [String]
      attribute(:version, kind_of: String, name_attribute: true)

      def program
        consul_template_program || provider_for_action(:consul_template_installation).program
      end
    end
  end
end
