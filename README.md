[![Build Status](https://img.shields.io/travis/visioncritical/consul_template/master.svg)](https://travis-ci.org/visioncritical/consul_template)
[![Code Quality](https://img.shields.io/codeclimate/github/visioncritical/consul_template.svg)](https://codeclimate.com/github/visioncritical/consul_template)
[![Code Climate](https://img.shields.io/codeclimate/coverage/github/visioncritical/consul_template.svg)](https://codeclimate.com/github/visioncritical/consul_template/coverage)
[![Cookbook Version](https://img.shields.io/cookbook/v/consul_template.svg)](https://supermarket.chef.io/cookbooks/consul_template)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE.md)

# Consul Template Cookbook

Installs & configures the Consul Template service.

## Requirements

### OS

```
supports 'ubuntu', '>= 12.04'
supports 'redhat', '>= 6.4'
supports 'centos', '>= 6.4'
supports 'windows'
supports 'freebsd'
```

### Cookbooks

```
depends 'poise', '~> 2.6'
depends 'poise-service', '~> 1.1'
depends 'rubyzip', '~> 1.0'
depends 'nssm', '~> 1.2'
```

## Usage

This cookbook was designed to expose most of configuration through [node attributes](#attributes). To use it, overide the attributes you need & include the default recipe in your runlist. You can alternatively customize everything by declaring the necessary [resources](#resources) yourself.

### Attributes

| Key  | Type | Description | Default |
| :---: | :---: | :---: | :---: |
| `['consul_template']['service_name']` | String | The name of the service | consul-template |
| `['consul_template']['version']` | String | The version of Consul Template to install | 0.14.0 |
| `['consul_template']['config']['conf_dir']` | String | The configuration directory for Consul Template | `/etc/consul-template/conf.d` OR `C:\Program Files\consul-template\conf.d` |
| `['consul_template']['config']['template_dir']` | Hash | A hash of Consul Template options to pass to the `consul_template_config` resource ([options](https://github.com/hashicorp/consul-template#options)) | {} |
| `['consul_template']['service']['data_dir']` | Hash | The data directory for Consul Template | `/var/lib/consul-template` OR `C:\Program Files\consul-template\data` |
| `['consul_template']['service']['environment']` | Hash | A list of environment variables that will be set for the service (Linux only) | {} |
| `['consul_template']['service']['user']` | String | The user to run the service as | consul-template |
| `['consul_template']['service']['group']` | String | The group of the service user | consul-template |
| `['consul_template']['service']['nssm_params']` | Hash | A hash of NSSM options to set for the service (Windows only) [options](https://nssm.cc/usage) | See [attributes file](attributes/default.rb) |

### Resources

#### consul_template_config

```ruby
consul_template_config 'consul-template' do
  conf_dir
  template_dir
  owner
  group
  # https://github.com/hashicorp/consul-template#options
  options
  # Optional, but recommeneded
  notifies :restart, "consul_template_service[#{service_name}]", :delayed
end
```

#### consul_template_installation

```ruby
consul_template_installation 'consul-template' do
  version
end
```

The following cannot be specified as a property on this resource, but they do have a direct effect on it. They're managed through node attributes.

```ruby
archive_url # node['consul_template']['archive_url']
install_path # node['consul_template']['install_path']
```

#### consul_template_service

```ruby
consul_template_service 'consul-template' do
  user
  group
  conf_dir
  data_dir
  environment
  nssm_params # Windows only
  program
end
```

#### consul_template

This resource is used for placing x2 files:

1. A configuration file containing a template block in your configuration directory.
2. An input template file (`.ctmpl`) in your template directory.

```ruby
consul_template 'example.json' do
  source
  cookbook
  content
  options
  conf_dir
  template_dir
  owner
  group
  destination
  command
  command_timeout
  perms
  backup
  # Optional, but recommeneded
  notifies :restart, 'consul_template_service[consul-template]', :delayed
end
```

This resource uses the [Template Content](https://github.com/poise/poise#template-content) helper from the [Poise cookbook](https://github.com/poise/poise#template-content). This exposes the following 4 properties:

* `source` - The name of the file or template (e.g. `template.ctmpl.erb`).
* `cookbook` - The name of the cookbook in which the file or template resides.
* `options` - A hash of variables to be evaluated in the template.
* `content` - The raw content of the file or template (used independently).

## Contributing

Please refer to [CONTRIBUTING.md]('./CONTRIBUTING.md').

## Extra

### Other Hashicorp Cookbooks:

* [Consul](https://github.com/johnbellone/consul-cookbook)
* [Vault](https://github.com/johnbellone/vault-cookbook)

### Thanks

Special thanks to:
* [John Bellone](https://github.com/johnbellone) for all his work on the Consul & Vault Cookbooks.
* [Noah Kantrowitz](https://github.com/coderanger) for creating the [Poise](https://github.com/poise) suite of Cookbooks.

