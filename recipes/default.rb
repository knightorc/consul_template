#
# Cookbook Name:: consul_template
# Recipe:: default
#
# Copyright 2016, Vision Critical Inc.
#

###
# Variables
###
version = node['consul_template']['version']
service_name = node['consul_template']['service_name']
user = node['consul_template']['service']['user']
group = node['consul_template']['service']['group']

# Windows only
node.default['nssm']['install_location'] = '%WINDIR%'

###
# Resources
###

poise_service_user user do
  group group
  not_if { node.windows? }
end

config = consul_template_config service_name do |r|
  owner user
  group group
  node['consul_template']['config'].each_pair { |k, v| r.send(k, v) }
  notifies :restart, "consul_template_service[#{service_name}]", :delayed
end

install = consul_template_installation service_name do
  version version
end

consul_template_service service_name do |r|
  program install.program
  conf_dir config.conf_dir
  node['consul_template']['service'].each_pair { |k, v| r.send(k, v) }
end
