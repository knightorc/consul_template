require_relative '../spec_helper'
require_relative '../../../libraries/consul_template_config'

describe ConsulTemplateCookbook::Resource::ConsulTemplateConfig do
  step_into(:consul_template_config)
  let(:chefspec_options) { { os: 'linux', platform: 'centos', version: '6.7' } }

  before do
    default_attributes['consul_template'] = {
      'config' => {
        'options' => {},
        'conf_dir' => '/etc/consul-template/conf.d',
        'template_dir' => '/etc/consul-template/templates'
      },
      'service' => {
        'user' => 'consul-template',
        'group' => 'consul-template'
      }
    }
  end

  context 'sets options' do
    config_content = <<-EOF.chomp
{
  "foo": "bar",
  "baz": "biz"
}
EOF

    recipe do
      consul_template_config 'consul-template' do
        options do
          foo 'bar'
          baz 'biz'
        end
      end
    end

    it { is_expected.to render_file('/etc/consul-template/conf.d/main.json').with_content(config_content) }
  end

  context 'removes configuration' do
    recipe do
      consul_template_config 'consul-template' do
        action :remove
      end

      it { is_expected.to delete_file('/etc/consul-template/conf.d/main.json') }
    end
  end
end
