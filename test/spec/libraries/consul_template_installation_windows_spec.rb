require_relative '../spec_helper'
require_relative '../../../libraries/consul_template_installation'

describe ConsulTemplateCookbook::Resource::ConsulTemplateInstallation do
  step_into(:consul_template_installation)
  let(:chefspec_options) { { platform: 'windows', version: '2012R2' } }

  recipe 'consul_template::default'

  it { expect(chef_run).to create_directory('C:\Program Files\consul-template\0.14.0') }
end
