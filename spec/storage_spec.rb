require_relative 'spec_helper'

describe 'Storage' do
  let(:id) { 237 }
  let(:subject) { Storage }
  let(:config) { Config.new }

  let(:client) {
    Client.new(config.source_key, config.source_url, 13)
  }

  context "When configured" do
    it "retrieves and stores a dashboard" do
      res = client.fetch_dashboard_body(id)
      pp res
      subject.write(res)
      expect(File.exist?("#{subject.path}/#{res["id"]}.json")).to be_truthy
    end

    it "can restore a saved dashboard" do
      res = client.fetch_dashboard_body(id)
      subject.write(res)

      res2 = subject.read(res["id"])

      expect(res2["id"]).to eql(res["id"])
    end
  end
end