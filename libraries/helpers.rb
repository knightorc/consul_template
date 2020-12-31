#
# Cookbook: consul_template
# License: MIT
#
# Copyright 2016, Vision Critical Inc.
#
# rubocop:disable Style/Documentation
module ConsulTemplateCookbook
  module Helpers
    extend self

    def arch_64?
      node['kernel']['machine'] =~ /x86_64/ ? true : false
    end

    def windows?
      node['os'].eql?('windows') ? true : false
    end

    # Returns a windows friendly version of the provided path
    # Gently plucked from https://github.com/chef-cookbooks/windows
    def win_friendly_path(path)
      path.gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || '\\') if path
    end

    def install_path
      install_path = node['consul_template']['install_path']
      return install_path unless install_path.nil?
      windows? ? join_path(program_files, 'consul-template') : join_path('/opt', 'consul-template')
    end    

    # Simply using ::File.join was causing several attributes to return
    # strange values in the resources (e.g. "C:/Program Files/\\consul\\data")
    def join_path(*path)
      windows? ? win_friendly_path(::File.join(path)) : ::File.join(path)
    end

    def program_files
      join_path('C:', 'Program Files') + (arch_64? ? '' : ' x(86)')
    end

    def default_conf_dir
      windows? ? join_path(install_path, 'conf.d') : join_path('/etc', 'consul-template', 'conf.d')
    end

    def default_template_dir
      windows? ? join_path(install_path, 'templates') : join_path('/etc', 'consul-template', 'templates')
    end

    def default_data_dir
      windows? ? join_path(install_path, 'data') : join_path('/var/lib', 'consul-template')
    end

    def consul_template_program
      node['consul_template']['service']['program']
    end

    # Returns Consul Template version folders that don't match the
    # version we're installing
    def other_versions
      # \ is an escape character for glob
      glob = join_path(install_path, '*.*.*').tr('\\', '/')
      folders = Dir[glob].select do |dir|
        version = ::File.basename(dir)
        (version =~ /\d+\.\d+\.\d+/) && (version != node['consul_template']['version'])
      end
      folders.map { |path| join_path(path) }
    end
  end
end
