require_relative '../spec_helper'
require_relative '../../../libraries/consul_template_installation'

describe ConsulTemplateCookbook::Resource::ConsulTemplateInstallation do
  step_into(:consul_template_installation)
  let(:chefspec_options) { { os: 'linux', platform: 'centos', version: '6.7' } }

  recipe 'consul_template::default'

  it { expect(chef_run).to create_directory('/opt/consul-template/0.14.0') }
end
