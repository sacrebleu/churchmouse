class Storage

  def self.base
    "#{Dir.pwd}/data"
  end

  def self.path(folder = nil)
    "#{base}/#{folder ? "#{folder}/" : ""}"
  end

  def self.list_local_folders
    Dir["#{base}/**"].select {|e|  File.directory?(e) }.map {|f| f.split(/\//)[-1] }
  end

  def self.list_local_dashboards(folder)
    Dir["#{base}/#{folder}/*.json"].map {|f| f.split(/\//)[-1].split(/\./)[0] }
  end

  def self.load_dashboard(folder, id)
    read(id, folder)
  end

  # write a dashboard structure to disk to preserve it between runs.
  def self.write(dashboard, folder = nil)
    p = "#{path(folder)}#{dashboard["id"]}.json"
    FileUtils.mkdir_p path(folder)
    File.open(p, "w") { |f| f.write(JSON.pretty_generate(dashboard)) }
  end

  def self.read(id, folder = nil)
    p = "#{path(folder)}#{id}.json"

    JSON.load File.open(p)
  end
end
