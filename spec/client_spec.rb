require_relative 'spec_helper'

describe 'Client' do
  let(:source) { {
    url: "https://metrics.nexmo.io:8443/grafana/",
    key: "eyJrIjoiWFRpUm0xM0g5c2F2MkE1Q1pCT0lDUDRWTjY5eUYxU00iLCJuIjoibWlncmF0aW9uIiwiaWQiOjEzfQ=="}
  }

  def mock(url)
    Client.new(nil, url, 1)
  end

  context "When validating" do
    it "Correctly builds a path regardless of slashes" do
      expect(mock("http://test/url").build("/test/path")).to eql("http://test/url/test/path")
      expect(mock("http://test/url/").build("/test/path")).to eql("http://test/url/test/path")
      expect(mock("http://test/url/").build("test/path")).to eql("http://test/url/test/path")
      expect(mock("http://test/url/").build("/test/path")).to eql("http://test/url/test/path")
      expect(mock("http://test/url//").build("/test/path")).to eql("http://test/url/test/path")
      expect(mock("http://test/url//").build("//test/path")).to eql("http://test/url/test/path")
      expect(mock("http://test/url//").build("test/path")).to eql("http://test/url/test/path")
      expect(mock("http://test/url/").build("//test/path")).to eql("http://test/url/test/path")
      expect(mock("http://test/url").build("//test/path")).to eql("http://test/url/test/path")
    end
  end


  context 'when it authenticates against the source grafana' do
    it 'receives a 200 OK if it uses the correct credentials' do

      client = Client.new(source[:key], source[:url], 1)

      res = client.list_folders
      expect(res[0]).to eql(:ok)
    end

    it "successfully retrieves a list of dashboards within the current organisation" do
      client = Client.new(source[:key], source[:url], 13)
      res = client.list_dashboards
      titles = res[1].map {|v| pp v; v["title"] }

      expect(titles.length).to eql(32)
    end

    it "successfully retrieves a list of folders within the current organisation" do
      client = Client.new(source[:key], source[:url], 13)
      res = client.list_folders
      titles = res[1].map {|v| pp v; v["title"] }

      expect(titles.length).to eql(3)
    end

    it "fetches the body of a dashboard versions by id" do
      client = Client.new(source[:key], source[:url], 13)
      res = client.fetch_dashboard_body(237)
      # expect(res[0]).to eql(:ok)
      expect(res["dashboardId"]).to eql(237)
    end

    it "fetches a list of dashboards by folder id" do
      client = Client.new(source[:key], source[:url], 13)
      _, res = client.list_dashboards(213)
      # expect(res[0]).to eql(:ok)
      expect(res.length).to eql(1)
    end
  end
end