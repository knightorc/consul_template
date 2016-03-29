require_relative '../spec_helper'
require_relative '../../../libraries/consul_template_service'

describe ConsulTemplateCookbook::Resource::ConsulTemplateService do
  step_into(:consul_template_service)
  let(:chefspec_options) { { os: 'linux', platform: 'centos', version: '6.7' } }

  recipe 'consul_template::default'

  it { expect(chef_run).to create_directory('/var/lib/consul-template') }
end
