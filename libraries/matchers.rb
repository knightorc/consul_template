if defined?(ChefSpec)
  def create_consul_template(message)
    ChefSpec::Matchers::ResourceMatcher.new(:consul_template, :create, resource_name)
  end

  def remove_consul_template(message)
    ChefSpec::Matchers::ResourceMatcher.new(:consul_template, :create, resource_name)
  end

  def create_consul_template_config(message)
    ChefSpec::Matchers::ResourceMatcher.new(:consul_template_config, :create, resource_name)
  end

  def remove_consul_template_config(message)
    ChefSpec::Matchers::ResourceMatcher.new(:consul_template_config, :create, resource_name)
  end

  def create_consul_template_installation(message)
    ChefSpec::Matchers::ResourceMatcher.new(:consul_template_installation, :create, resource_name)
  end

  def remove_consul_template_installation(message)
    ChefSpec::Matchers::ResourceMatcher.new(:consul_template_installation, :create, resource_name)
  end

  def enable_consul_template_service(message)
    ChefSpec::Matchers::ResourceMatcher.new(:consul_template_service, :create, resource_name)
  end

  def disable_consul_template_service(message)
    ChefSpec::Matchers::ResourceMatcher.new(:consul_template_service, :create, resource_name)
  end
end
