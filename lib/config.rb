class Config

  def config
    @config ||= YAML.load_file("#{Dir.pwd}/config/config.yaml")
  end

  def source_key
    config["source"]["key"]
  end

  def source_url
    config["source"]["url"]
  end

  def source_org
    config["source"]["org_id"]
  end

  def target_key
    config["target"]["key"]
  end

  def target_url
    config["target"]["url"]
  end

  def target_org
    config["target"]["org_id"]
  end
end