#
# Cookbook: consul_template
# License: MIT
#
# Copyright 2016, Vision Critical Inc.
#

extend ConsulTemplateCookbook::Helpers

default['consul_template']['service_name'] = 'consul-template'
default['consul_template']['version'] = '0.14.0'

default['consul_template']['config']['conf_dir'] = default_conf_dir
default['consul_template']['config']['template_dir'] = default_template_dir
# https://github.com/hashicorp/consul-template#options
default['consul_template']['config']['options'] = {}

default['consul_template']['service']['data_dir'] = default_data_dir
# Linux only
default['consul_template']['service']['environment'] = {}
default['consul_template']['service']['user']  = 'consul-template'
default['consul_template']['service']['group'] = 'consul-template'
# Windows only
default['consul_template']['service']['nssm_params'] = {
  'AppDirectory'     => default_conf_dir,
  'AppStdout'        => '',
  'AppStderr'        => '',
  'AppRotateFiles'   => 0,
  'AppRotateOnline'  => 0,
  'AppRotateBytes'   => 0
}

###
# Noteworthy Overrides
###
# default['consul_template']['archive_url']
# default['consul_template']['install_path']
# default['consul_template']['service']['program']
# default['poise-service']['consul-template']['template'] = 'cookbook:erb_file'
