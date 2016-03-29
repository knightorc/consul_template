require_relative '../spec_helper'
require_relative '../../../libraries/consul_template_config'

describe ConsulTemplateCookbook::Resource::ConsulTemplateConfig do
  step_into(:consul_template_config)
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

  context 'sets options' do
    recipe do
      consul_template_config 'consul-template' do
        options do
          foo 'bar'
          baz 'biz'
        end
      end
    end

    it { is_expected.to render_file('C:\Progam Files\consul-template\conf.d\main.json').with_content(<<-EOF.chomp) }
{
  "foo": "bar",
  "baz": "biz"
}
EOF
  end

  context 'removes configuration' do
    recipe do
      consul_template_config 'consul-template' do
        action :remove
      end

      it { is_expected.to delete_file('C:\Progam Files\consul-template\conf.d\main.json') }
    end
  end
end
