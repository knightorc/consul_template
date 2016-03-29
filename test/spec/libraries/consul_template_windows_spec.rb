require_relative '../spec_helper'
require_relative '../../../libraries/consul_template'

describe ConsulTemplateCookbook::Resource::ConsulTemplate do
  step_into(:consul_template)
  let(:chefspec_options) { { platform: 'windows', version: '2012R2' } }

  before do
    default_attributes['consul_template'] = {
      'config' => {
        'options' => {},
        'conf_dir' => 'C:\Progam Files\consul-template\conf.d',
        'template_dir' => 'C:\Progam Files\consul-template\templates'
      }
    }
  end

  context 'create template' do
    template_content = '{{with secret "secret/passwords"}}{{.Data.password}}{{end}}'
    config_content = <<-EOF.chomp
{
  "template": {
    "backup": true,
    "command": "restart-service name",
    "command_timeout": "60s",
    "destination": "C:\\\\temp\\\\result",
    "source": "C:\\\\Progam Files\\\\consul-template\\\\templates\\\\example.ctmpl"
  }
}
EOF

    recipe do
      consul_template 'example.json' do
        content template_content
        destination 'C:\\temp\\result'
        command 'restart-service name'
        command_timeout '60s'
        backup true
      end
    end

    it { is_expected.to render_file('C:\Progam Files\consul-template\conf.d\example.json').with_content(config_content) }
    it { is_expected.to create_file('C:\Progam Files\consul-template\templates\example.ctmpl').with_content(template_content) }
  end

  context 'remove template' do
    recipe do
      consul_template 'example.json' do
        action :remove
      end

      it { is_expected.to delete_file('C:\Progam Files\consul-template\conf.d\example.json') }
      it { is_expected.to delete_file('C:\Progam Files\consul-template\templates\example.ctmpl') }
    end
  end
end
