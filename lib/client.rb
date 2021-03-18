require "httparty"
require_relative "storage"

class Client

  def initialize(key, base, org)
    @key = key
    @base = base.gsub /\/+$/, '' # strip trailing / characters
    @org = org # keep it real :P
  end

  def server
    @base
  end

  def self.source
    config = Config.new
    Client.new(config.source_key, config.source_url, config.source_org)
  end

  def self.target
    config = Config.new
    Client.new(config.target_key, config.target_url, config.target_org)
  end

  def list_folders
    _list"dash-folder"
  end

  def list_dashboards(folder_id = nil)
    _list "dash-db", folder_id
  end

  def _list(type, folder_id = nil)
    p = {type: type}
    if folder_id
      p[:folderIds] = folder_id
    end
    get("/api/search", p)
  end

  def search_dashboards(query)
    p = {query: query}
    get("/api/search", p)
  end

    # need to get the max version of the dashboard
  #   /api/dashboards/id/:id/versions
  # then fetch that version
  #   /api/dashboards/id/1/versions/:version
  def fetch_dashboard_body(id)
    v = latest_version(id)
    result, response = get("/api/dashboards/id/#{id}/versions/#{v}", {})
    raise response unless result == :ok
    response
  end

  def latest_version(id)
    result, response  = get("/api/dashboards/id/#{id}/versions", {})
    raise response unless result == :ok
    response.collect{|v| v["version"] }.max
  end

  def build(_path)
    path = _path
    if path.start_with?('/')
      path.gsub! /^\/+/, '' # strip leading / characters
    end
    # "#{@base}#{path.start_with?('/') ? path[1..-1] : path }"
    "#{@base}/#{path}"
  end

  def handle(response)
    return [:ok, JSON.parse(response.body)] if response.code == 200
    [:error, response.body]
  end

  def get(path, params)
    p = build(path)
    response = HTTParty.get(
      p,
      query: params,
      headers: auth_headers,
    )

    handle(response)
  end

  def auth_headers
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'Authorization' => "Bearer #{@key}",
      'X-Grafana-Org-Id' => @org.to_s
    }
  end
end