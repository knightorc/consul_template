require_relative '../spec_helper'
require_relative '../../../libraries/consul_template_service'

describe ConsulTemplateCookbook::Resource::ConsulTemplateService do
  step_into(:consul_template_service)
  let(:chefspec_options) { { platform: 'windows', version: '2012R2' } }

  recipe 'consul_template::default'

  it { expect(chef_run).to create_directory('C:\Program Files\consul-template\data') }
end
