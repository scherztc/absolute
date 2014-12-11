class Ingest
  def initialize

  end

  def pid_list

  end

  def remote_dir
    return @remote_dir if @remote_dir
    ingest_config_file = Rails.root.join('config','ingest.yml')
    @remote_address = YAML.load_file(ingest_config_file)
    return @remote_address
  end
end
