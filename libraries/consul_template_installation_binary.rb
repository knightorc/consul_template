#
# Cookbook: consul_template
# License: MIT
#
# Copyright 2016, Vision Critical Inc.
#
require 'poise'
require_relative './helpers'

module ConsulTemplateCookbook
  module Provider
    # A `consul_template_installation` provider which manages consul-template binary
    # installation from remote source URL.
    # @action create
    # @action remove
    # @provides consul_template_installation
    # @example
    #   consul_template_installation '0.14.0'
    # @since 0.1.0
    class ConsulTemplateInstallationBinary < Chef::Provider
      include Poise(inversion: :consul_template_installation)
      include ::ConsulTemplateCookbook::Helpers
      provides(:binary)
      inversion_attribute('consul_template')

      # @api private
      def self.provides_auto?(_node, _resource)
        true
      end

      # Set the default inversion options.
      # @return [Hash]
      # @api private
      def self.default_inversion_options(node, new_resource)
        archive_basename = binary_basename(node, new_resource)
        url = node.archive_url % { version: new_resource.version, basename: archive_basename }
        super.merge(
          version: new_resource.version,
          archive_url: url,
          archive_basename: archive_basename,
          archive_checksum: binary_checksum(node, new_resource),
          install_path: node.install_path
        )
      end

      def action_create
        archive_url = options[:archive_url] % {
          version: options[:version],
          basename: options[:archive_basename]
        }

        notifying_block do
          # Remove any version that isn't the one we're using
          stop_consul_template unless other_versions.empty?
          other_versions.each do |dir|
            directory "Remove version - #{dir}" do
              path dir
              action :delete
              recursive true
            end
          end

          directory join_path(options[:install_path], new_resource.version) do
            recursive true
          end

          zipfile options[:archive_basename] do
            path join_path(options[:install_path], new_resource.version)
            source archive_url
            checksum options[:archive_checksum]
            not_if { ::File.exist?(program) }
          end
        end
      end

      def action_remove
        notifying_block do
          directory join_path(options[:install_path], new_resource.version) do
            recursive true
            action :delete
          end
        end
      end

      def program
        @program ||= join_path(options[:install_path], new_resource.version, 'consul-template')
        windows? ? @program + '.exe' : @program
      end

      def self.binary_basename(node, resource)
        if node.arch_64?
          ['consul-template', resource.version, node['os'], 'amd64'].join('_')
        else
          ['consul-template', resource.version, node['os'], '386'].join('_')
        end.concat('.zip')
      end

      def self.binary_checksum(node, resource)
        tag = node.arch_64? ? 'amd64' : '386'
        case [node['os'], tag].join('-')
        when 'darwin-i386'
          case resource.version
          when '0.18.1' then '44c26daf01517e493de15e0d93afa500cb38fffdd12192abc58a9f85734224a0'
          when '0.18.0' then 'a3cb126143275374234255fae929c06193434761cc365854e87cf0fa552312fd'
          when '0.16.0' then '326f1bc31e770758b952f7313afcf89e7227ee2a472f4e6fe5c0f763debc48ee'
          when '0.15.0' then '40a0b46fa13f69be1a5148a5e9d1d6420a61576170a52bacd51578a2584d9c47'
          when '0.14.0' then '1dd6db71e745fface4aa15f1ac9ca72ca746077fe62b8e60abf2955b19ec2f98'
          when '0.13.0' then '3570ac6762d860d5a87c26d9fc6d97df577bd2bdcfba804a91d89a9703d2ab27'
          when '0.12.2' then '2bb97c26b028ebfbb5ca9a4178d3f8c92426acfc44cc15b7b5efa9ab2bc88832'
          when '0.12.1' then '8e2bc975640d6e12894e5f8f15160acea7f3cff8292b806f061a8ec331f10148'
          when '0.12.0' then 'f5b46f2cca488c9f889eacb2e62718daddd44d3cde93f14ea136313deace44a9'
          when '0.11.1' then '9ea06a9ddbb349d227f5da554eb40e250de96a4a66c30baee0d31e5323c4a53a'
          when '0.11.0' then 'e8c5847f198d20d1c02362202ff82884ba6831f54e77ad118d2d903be7c37be2'
          when '0.10.0' then '55d71bafe530c645e37017ad1f3e4010de4c84d6a12c5cf48ee499c1bb54503c'
          end
        when 'darwin-amd64'
          case resource.version
          when '0.18.1' then 'e807abf95061177241d8fcc6b80fee635d236a47a8befc39600a67e4cfda2f83'
          when '0.18.0' then 'a496c786f10e1abfc4c607637477fdcee829e3a25caa37ad4ae69714a927ea15'
          when '0.16.0' then '5f932f3601a1b5ff9e205f130635fa62638ea66e335a420457e7df39d95e4796'
          when '0.15.0' then '1ecc48bc3c5df7537e4857693322b46dc5db5563b84e8225b24df439e287f9e3'
          when '0.14.0' then '37fc8aca13020180b367bb1d277242adb11526394f4f0ce1c3d5f0ec8d2071d8'
          when '0.13.0' then 'ea7ec46b5922f497b5ffea8a7de2eb33268fc7ff18bd20e1a35af9334c98b5b9'
          when '0.12.2' then 'a9ab8e16cb02729153ec72a53f9f9f73efa0259521200467482fb34bd3e893b1'
          when '0.12.1' then '9ccdfd5a99ed69cd694bbaa10ff45d1a660eda2d74ba010dc0400641959e5e73'
          when '0.12.0' then 'a58e2d39d3af603af7e385d127d359844a5f752f2f1e1a1885f5fda05e8e4bfb'
          when '0.11.1' then '6915e16969533ef27964199ff4194155cfa6deb43d1a863287d02c0c1b3067ff'
          when '0.11.0' then 'e0a512ec9ac0c6d84ffe409def83b823a2308f8bdb32b902e26df781585eb5cc'
          when '0.10.0' then 'd17878c99241c09182718d7a4f967cd304fb7d89aaea8c16901a8ec85fa04ebc'
          end
        when 'freebsd-i386'
          case resource.version
          when '0.18.1' then '00fc58ed5c2dca1362018b84dd3ede684df447022dd0170c347387a0bb3178b1'
          when '0.18.0' then 'cabd90220af55ce9341c3bd52b69095f60fe1dadc8144c1ce8ec0ec4059ef0f0'
          when '0.16.0' then '332dd67a2e7f525caae155103cf9b99b85c2a900c65b19df254e7bbb75c34514'
          when '0.15.0' then '0e235220afc23d874b44683209fb696a2fe3d17ef7a3ef7ebb4d6033d48ccdc1'
          when '0.14.0' then '6e7f0912affde1f09c7828dc33da61170d204e151ef2bfd64062e6ff9b10e7eb'
          when '0.13.0' then 'e5d4fa5012328c6bac6a61ca9ec2d32ed7fb9febd2585c20a0fb8f199d4e073f'
          when '0.12.2' then '366cdb13be1206e676d5a93f634c33ea11ab6bcb6d59ace2c3004e81cb719d7d'
          when '0.12.1' then '62739d1475c712d9fa20a22d445209a92467f08a387e3295550593eed32fe6f6'
          when '0.12.0' then 'a71dc397724b7724b1d8ce18abb79e08762cda8e9411fdb9d73fa34b5264c54e'
          when '0.11.1' then 'feeae8a211f4b56a42597514fad5e4b65be2d6f124bf37b2c1ad840c718fa4a9'
          when '0.11.0' then 'cf2fdaca91fafddebd9a8e76dd54e16de5bccc28320188354f40a0919aafa04c'
          when '0.10.0' then '00d7f1a1622324e70c2846f90f223ffd7bf7e2e4de6fb835255f625639b32401'
          end
        when 'freebsd-amd64'
          case resource.version
          when '0.18.1' then '5f752338a02fd6557cf780676ba74f7f4cf3c35b6c9f0e48af50b2182a4f95cc'
          when '0.18.0' then '4eb4fff3e8d54d084c60f4cb41acf2045750cfd73b9cf2a031500854bd1cef35'
          when '0.16.0' then '12524bc543c9ce6c964b18177106a0b77c47b0afcff058db5c9bf21e0bc48b76'
          when '0.15.0' then '2ba21a8ce67b8e44178cadba8542e9c6eac6a37372b6f0682f405e24d0c7947b'
          when '0.14.0' then 'f666a91006230acceac5f65f28d095cd84746686fc35189e5843b6c8198c5d70'
          when '0.13.0' then '633cb879fad680d3a285f03bc365e34ad190e14f212ac9764e47f8fed8641551'
          when '0.12.2' then '7f82bc088587bc1b93868f506866810eac249f3469f881dde0ec09010d0f29dc'
          when '0.12.1' then '517d48f8262240076d24f15072ea44f8078afab18eea1bbfe2e8afb9f00fc7f3'
          when '0.12.0' then 'f9f8cf8687a69497c3465711c2a199d33ecd8576c1a7a1a3a0a984a68967b1fb'
          when '0.11.1' then '22b20bfea9233bd388081008a2d39e79718271b5701c1cd6e169371681701bc0'
          when '0.11.0' then 'e08a715c5bd916d1c0d08d19774eb89da68ce7a1d72b4ce496c3d5cd77afae60'
          when '0.10.0' then 'de43dd980bc331b669c5bd09840d4a801fe782645d53e1da0e8a543e085e3276'
          end
        when 'linux-i386'
          case resource.version
          when '0.18.1' then '6704de6125f4d1aa5008d9a0a77daa709802d6f30ffccf139e8ff05065f42143'
          when '0.18.0' then 'e9c5d012cba33966b31c91b2638b63ad52f35037719628fbfbd351c5a4551f2c'
          when '0.16.0' then '497235d49a3c32b605416536a721dbcecb817d75f41f42a5a3e3dc7d6d74f7ff'
          when '0.15.0' then '65c6207993649f44b7316723c3e02d184556b133443b3b2a7e2a3e6720753680'
          when '0.14.0' then '4026cbd5e5a0bbaf851768de1e9d5bfa6bb5a0e73cddb7458974e8400e92786d'
          when '0.13.0' then '47b2bca5c0b544e0a598bd7a317775095311f333cab5df9c2bee4acd27ddb4eb'
          when '0.12.2' then 'ec65fd9172cc991ba9c30d8e6b04ddd45c37af489af07682ff96be7d361cbc60'
          when '0.12.1' then '5ea6fc15058fc3c5b1e2f28cbb291761239bd69e358385eb36c622c21bb55f00'
          when '0.12.0' then 'd917cdb9035ff49d0a983cb7a283d1827e9303a5cac22dc5f846ccf7384189e7'
          when '0.11.1' then '931b11feeca81cb01e1024ef6fb96d49acff470aea153081661b76b2b4abe6b3'
          when '0.11.0' then '41565318a7f4de7bc423be0b7487563fa0afd36cde20f92947f033684406644c'
          when '0.10.0' then '2369425e9822153c90a13be8f7656ce0efefcdc52e44ea319f83c5dbcae36ad7'
          end
        when 'linux-amd64'
          case resource.version
          when '0.18.1' then '99dcee0ea187c74d762c5f8f6ceaa3825e1e1d4df6c0b0b5b38f9bcb0c80e5c8'
          when '0.18.0' then 'f7adf1f879389e7f4e881d63ef3b84bce5bc6e073eb7a64940785d32c997bc4b'
          when '0.16.0' then '064b0b492bb7ca3663811d297436a4bbf3226de706d2b76adade7021cd22e156'
          when '0.15.0' then 'b7561158d2074c3c68ff62ae6fc1eafe8db250894043382fb31f0c78150c513a'
          when '0.14.0' then '7c70ea5f230a70c809333e75fdcff2f6f1e838f29cfb872e1420a63cdf7f3a78'
          when '0.13.0' then '6c3017dee5c75eebdecb83cd0a64ce04cd91dd8660aea432b479c1b807b06ed0'
          when '0.12.2' then 'a8780f365bf5bfad47272e4682636084a7475ce74b336cdca87c48a06dd8a193'
          when '0.12.1' then '693c52a2b1aed9b63584f47c377efd0fc349df3616985a0709246faaf9a80c8e'
          when '0.12.0' then '1fff23fa44fd0af0cb56f011a911af1e9d407a2eeb360f520a503d2f330fdf43'
          when '0.11.1' then 'aa681229e77f93c569eca2883f674184d05d1bdc0ca33234e28c2b60f17dc398'
          when '0.11.0' then '1162de7ecd6303dccc3e8c3cb7faaecb55d1577eea9b690c56cb156102694f15'
          when '0.10.0' then 'f7ebda868e9c00f61a0b55bf2257d9c711de5c20c175e0b05e2d8f5bc25eca4e'
          end
        when 'netbsd-i386'
          case resource.version
          when '0.18.1' then '3dd4bc9709cea674a50dec1c51c65fcb54444c70ca6f528013ac1d5043d9ee2c'
          when '0.18.0' then '5bf61c6ca8e677e77489cf53f8245ecda185e0b289e259f08a13c4f4b1236c68'
          when '0.16.0' then '237a7f0b2bec644ae8a949d32228b02a37854eaebc9f618c0ee2c2f5b0b5d480'
          when '0.15.0' then 'ca1de7a352621f706eeda69729e339aaa6f2eec7ad9e82672321ad60d7fb3917'
          when '0.14.0' then 'b90a1b9f12de1171cbca1239d532152b74e5aa2d46dbcf3e4b5d5d49f65e6bca'
          when '0.13.0' then 'f3895a12dcd204200d235092a7237624aed351f2eeac8417e3aaa9f1fe594a65'
          when '0.12.2' then '7a8896bce321fd70de876c547e2ecfc3d5c58297e126eef9d125f00daf84e9f5'
          when '0.12.1' then '8d1e82e7b3523089dbf853dd55533d18bc3219dd9cb006e487c1face34c2e91a'
          when '0.12.0' then '6dc98e217632a063f3f8a12ff02c99d1ef8edd1d10261860eea6d9889fc80247'
          when '0.11.1' then 'f5e0fcef7dcbdca3c03fc193f93f32a83a45e1bbd04255e873b00c497835171b'
          when '0.11.0' then '6b700def29163ed99e3f3cdd58d7cd51f2db74e56b02f01b4f9b84b5e8c3f09b'
          when '0.10.0' then 'cfe819fe4928e354ce6a7e1875e6a055e1a4510e1adc7b62f7d10dbeea7e8f8b'
          end
        when 'netbsd-amd64'
          case resource.version
          when '0.18.1' then '791b24397f2fd754a39a4190a7d830d198028d68eee030f3e15b4f3a59799bd0'
          when '0.18.0' then '3bc621c0004c1847182c4133a2fa05b8c27fc65075b057891ad4d931d5b39a27'
          when '0.16.0' then 'b169061ea5ddcd785833eceaf7ef9eca2a9fb83f579f851dd4c9419ea2834905'
          when '0.15.0' then '0320466c83d256ae9a2a9104b8d14b24a17ad240ec9254ee75e7b9cb3aba8dee'
          when '0.14.0' then '25a7c3f0ee60bdac33e1fe9b03972f68611e97f20bddf07432d159ab75f8a1d0'
          when '0.13.0' then 'c543f98ddfe91c6cc6740554d0d79e1cad1fe90abd5c56ae712da91ce28e0773'
          when '0.12.2' then 'd22c4720168da8ec14785bfef7cf6e0e5facd5a1ca7fdc3e7de8d427b9a626a8'
          when '0.12.1' then '205437a8408c58a1601e1e5d95de057afe2b5b6317a5c496984c09f94c0990f4'
          when '0.12.0' then 'ad6e09daef99c832ddccd9c618b89d469b7ea80cb1dcfde35ba6f91ca7cd98a8'
          when '0.11.1' then '2f63a6c21fd25819fde4ca1275de4020d278cfcc03064913327d13659e6705c4'
          when '0.11.0' then '8f9ced69b1244d741e6d372241e9943b04e5bfd48eb0ba8f77bf5a633c01806a'
          when '0.10.0' then '0f2868c38267370b88e64620717453e06de3ca3da7b08dd2bb3f1bd40aa7f513'
          end
        when 'openbsd-i386'
          case resource.version
          when '0.18.1' then '396da8f55bc5001d66766c93dca345bf080ade93b1c5d3783037571db4cfaade'
          when '0.18.0' then '4362bbac5049b4217956133f4df68f02650efe2ecdf812a4a072f4b99f208995'
          when '0.16.0' then 'fcd723775c57b1b15d8402a80e859f8ddc52bc11f1ebc5515514a14149c63d5f'
          when '0.15.0' then 'c276cce7f8f23d45ce846e948ed88b46e53748511277f3c9a966d68716948fff'
          when '0.14.0' then '04c9d6a67566abcc78fbb67f8ce7c6bf2df3b90d9df0a27846e4b596221754d7'
          when '0.13.0' then 'c65b21ec280a72f94acf60c155133d81ebbba4cef425fcdca2f872b6435ef98f'
          when '0.12.2' then 'ec4737a38eb43eb373991209c9fe9abe5c1b2ac41074ba1493eeb5f889072396'
          when '0.12.1' then '2478da588a5888b51f88926d37aa507652fb4ba4d44e826ca802d0c50f8b2247'
          when '0.12.0' then '70ce68e9e2c826d2dc152ed48473df3faf32a93ad9a00cc2dcd8775d6fc3d3a0'
          when '0.11.1' then '929133195f776eaf83ca8e4fbc6b3daa33c98a432da36985e107dcca0acb6c69'
          when '0.11.0' then '145b3ce462b998990a440d57e949b24514741342348397c631fb15f220bb5a94'
          when '0.10.0' then 'fee6c258a06a12cd2f68696c3b9d9d0c9faa311afd1b17dcf94f981daa6a74d5'
          end
        when 'openbsd-amd64'
          case resource.version
          when '0.18.1' then '59a0297cf2ad1058626409ee38192d5c17446d7e61e015421aadb47fc8a76698'
          when '0.18.0' then 'fcf05b93273e415fa5054956ea37b4d4bd34066b11cb07d238183264937a2017'
          when '0.16.0' then '602705d76906b23271195911878836100c7e0bc2434f6fc126e722588647e2f8'
          when '0.15.0' then 'f510571a47f42a03e6de7caa1f477673ea8e58764b17849dc7103ecca2aa63d9'
          when '0.14.0' then '2d1e7121d80ba31c262910714bc5587b6f70abcd613f5d26f8b3c1366c36b77d'
          when '0.13.0' then 'df1343655e916960c030a7909cc80f9792076ea8cd0cc80daa083da321bb6e1c'
          when '0.12.2' then '1fd417adb65ef8d071d5d27fbaaa20cbc974df0a6c5c8c46c3054aaf71c4f67a'
          when '0.12.1' then '29cb42881313438e42beeea1ef05a810b854e58bf6e061be2e93f985897d70ab'
          when '0.12.0' then 'd8f8a6b3f1e9cbc15800a12d6e5cfc3e79b9e50d16ce95ac27f093a616e45c97'
          when '0.11.1' then '5d1fef7e1e408721d3cdfd043c2d4343692887444b96cc63916bc2609b481ebc'
          when '0.11.0' then 'fe0c3462f5dec8979f186292428091ff779ba45d2d9b45aba4bc6cdc67312edd'
          when '0.10.0' then 'b88b2418429309483ed0304f4b0799c535325b745cf69909dd773a962ebbb3d3'
          end
        when 'solaris-amd64'
          case resource.version
          when '0.18.1' then 'a584acda799ef405c068ea5a6f817af3301a2b555927e5abeb2503b3390ab012'
          when '0.18.0' then '8713d1ba5209a1dbec729df9f2698c033be770bb1a54f1c056a2beffd6ad9812'
          when '0.16.0' then 'd862879d5d0b85c1f6e49c459ab4a89530cf99d9d7ec65e7a51ee3cb9543bfab'
          when '0.15.0' then '092b339a1e3487b979caa26aa276a91a4b5f7c964971bc9793f07154ad44ddf7'
          when '0.14.0' then '5ab285e00ce76f129d28297b0321ca786457daaa9fbe890275bf2bca078966fa'
          when '0.13.0' then 'b13080b6f04a0ae929c0fc0aa1ffb860a10a36c7f59ce50d2425d7d149305028'
          when '0.12.2' then 'f9df7b0431915ff41e2e718f38c5c5b992bec578636bf5b57d09eb598c25c932'
          when '0.12.1' then '640d62695fece43f86f578684a7f343cdcc61c5e492015f1681378e397f212d1'
          when '0.12.0' then '4a97652b6fd6a3afd243bcb3c3192b82ebbc8f90ca3dbc93e3f2a456d9d161d5'
          when '0.11.1' then '82dcc869f64aa6527ced1b4f45a0d44a79291a70ab3ecbfb14e96f06624e94ec'
          when '0.11.0' then '465d23c93b587a165cd8350d152c045b4ed36077b2ea45e407201cbf7d956e13'
          when '0.10.0' then '63f2cef5adb26572c015ff003d0e0dba2b438b0b1dc3dd506abdd39a31c81e07'
          end
        when 'windows-i386'
          case resource.version
          when '0.18.1' then '8ce401ce123dda00e072e2ec21104ef9345b03ff6690096926cdd652714e399b'
          when '0.18.0' then '5d331a8a05f8dfc39cbb244775731a758fcea4de9d7f0926ada79d86455836b3'
          when '0.16.0' then '293b5009167eb611cacc2fb2910b8f92c1b7bce12d19d87ca158a78049463c98'
          when '0.15.0' then '7959b7624eef71fcac531bfa908c245d26ba8363bf61f19b4e027e649791dfd9'
          when '0.14.0' then '2dbc3d130356f9a52c2a0e1c045fc109bf06fe6692f0ece94ef1dfb894a37dca'
          when '0.13.0' then '905036a586526cc148c0af7cf26cbf036683938676ee7cd394946ff1e45d52b1'
          when '0.12.2' then 'a6e11131caaa910c260812186510ac0b5e5df727af57eb0ee1a1250c08fb68d0'
          when '0.12.1' then '3833cedde335a7e5c8cf3bc9ad36e4163985034d7b0ea46b6c019c93db97d942'
          when '0.12.0' then 'c072afe81e25d65146278f6e8b1b01cfd3f8fbcb4db61d5929c3d193c764838f'
          when '0.11.1' then '90bb110da1cb0fa600a69467133d2698edbf278fb1724c887692d73c47196cd1'
          when '0.11.0' then '943216d2159c954e898e6fd66aa05f87e865da5a18c624ccd4e7d10f8044a0a2'
          when '0.10.0' then '5687c506e68c9c035dc02ba476e505696de2ae6453714a48b0e1ef270e04a580'
          end
        when 'windows-amd64'
          case resource.version
          when '0.18.1' then 'cd2a265044bb64796fb8ecc97d1024fe4c24d1275e5783ef54acdf7e58fc4558'
          when '0.18.0' then '0ca5f3897b30c52e4b362656d22184c5e3187d56ea6dc915e621dfea2aef662d'
          when '0.16.0' then '824eff8a540510dd185023def1b957a09dc62bc2cbaab820525ea038c6bd5d0d'
          when '0.15.0' then '40ff124f91b5ec1405621c0b72e26e2877b40a6217770488464b8e97015f1648'
          when '0.14.0' then '48dccd0134df43b6ebdceddc4185e8c25fea169e43feeccb7ca4e42ce299bc2c'
          when '0.13.0' then '8ce115ce8cc623ac18c795d17db66d6c8b3f421ce6497221d5886c34b00ff8cc'
          when '0.12.2' then '6dad0d278afcdadf2e99a88c48d2743f282e4548dea3e4d11fa3f8ff7e8b1c8f'
          when '0.12.1' then 'd95796b1f9a56c1534e023cf5453f51c84fcaab977a29e4cc2c4a1af3808a19d'
          when '0.12.0' then 'fcb4ae4e64c99222624ea061beff4edbb9aff3c8a535ade4696b39ae0df29ef8'
          when '0.11.1' then '719c5df3f5bd9ecb04d13215f2aed3fa9cc76b554576c346f1ffd5a006f84806'
          when '0.11.0' then '2a88e8f4b6c6828a82f1a919fe208407fc419c09a5eb302f116890c2fb7f6487'
          when '0.10.0' then '7c6f30a7ec5939b5df1dec6c2ce5ea8ea01ff4938969b32f83211cf2278f9466'
          end
        end
      end
    end
  end
end
