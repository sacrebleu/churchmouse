require_relative 'spec_helper'

describe Config do

  it "loads the source config and makes keys available" do

    expect(subject.source_key).to_not be_nil
    expect(subject.source_url).to_not be_nil

    expect(subject.source_url).to eql("https://metrics.nexmo.io:8443/grafana")
  end
end