require_relative '../spec_helper'
require_relative '../../../libraries/consul_template'

describe ConsulTemplateCookbook::Resource::ConsulTemplate do
  step_into(:consul_template)
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

  context 'create template' do
    template_content = '{{with secret "secret/passwords"}}{{.Data.password}}{{end}}'
    config_content = <<-EOF.chomp
{
  "template": {
    "backup": true,
    "command": "service name restart",
    "command_timeout": "60s",
    "destination": "/tmp/result",
    "perms": "0440",
    "source": "/etc/consul-template/templates/example.ctmpl"
  }
}
EOF

    recipe do
      consul_template 'example.json' do
        content template_content
        destination '/tmp/result'
        command 'service name restart'
        command_timeout '60s'
        perms '0440'
        backup true
      end
    end

    it { is_expected.to render_file('/etc/consul-template/conf.d/example.json').with_content(config_content) }
    it { is_expected.to create_file('/etc/consul-template/templates/example.ctmpl').with_content(template_content) }
  end

  context 'remove template' do
    recipe do
      consul_template 'example.json' do
        action :remove
      end

      it { is_expected.to delete_file('/etc/consul-template/conf.d/example.json') }
      it { is_expected.to delete_file('/etc/consul-template/templates/example.ctmpl') }
    end
  end
end
