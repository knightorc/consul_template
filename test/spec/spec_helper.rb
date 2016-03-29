require 'chefspec'
require 'chefspec/berkshelf'
require 'poise_boiler'
PoiseBoiler.kitchen(no_gem: true, cookbook_name: 'consul_template')
require 'poise_boiler/spec_helper'

require_relative '../../libraries/helpers'
require_relative '../../libraries/nssm_helpers'
