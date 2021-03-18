require 'rubygems'

Bundler.require(:default)

require 'optparse'

Dir["#{Dir.pwd}/lib/**/*.rb"].each { |f| require f }
# legacy
# curl -H "Authorization: Bearer eyJrIjoiOEdobDRFOGQ3NzFhN3k5YWVCZE91VWJxMTV6YnpJOG4iLCJuIjoibWlncmF0aW9uIiwiaWQiOjEzfQ==" https://metrics.nexmo.io:8443/grafana/api/dashboards/home

# new
# curl -H "Authorization: Bearer eyJrIjoiNVFOdWdFblBtNk1Ma2dzRVVldDBHSndiVFh1UE11dXkiLCJuIjoibWlncmF0aW9uIiwiaWQiOjEzfQ==" https://grafana.nexmo.cloud/api/dashboards/home

# workflow
#  1. establish list of folders on source server
#  2. establish list of folders on target server
#  3. group dashboards by folder
#  4. process each folder, retrieving dashboard and
#   1. updating datasources
#   2. updating alerts
#   3. moving annotations and alerts to correct section of json document
#   4. publishing to target server
#
#  5. process general folder (folder id 0)
#   1. updating datasources
#   2. updating alerts
#   3. moving annotations and alerts to correct section of json document
#   4. publishing to target server
#
# validation
#
# Todo: ensure this script is idempotent.  It should simply run again and again, merging any outstanding changes.

require_relative 'migrator'

unless ENV["RSPEC"]
  options = {}

  OptionParser.new do |opts|
    opts.banner = "Usage: app.rb [options]"

    opts.on("-e", "--export", "Export dashboard configuration from the source grafana host") do
      options[:export] = true
    end
    opts.on("-i", "--import", "Import dashboard configuration into the target grafana, merging where possible") do
      options[:import] = true
    end
    opts.on("-d", "--show-diffs", "Print diffs between source and target dashboards to stdout") do
      options[:visual_diff] = true
    end
    opts.on("-m", "--merge", "Attempts to resolve differences in dashboards before showing differences") do
      options[:attempt_merge] = true
    end

    opts.on("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
  end.parse!

  if options.empty?
    puts  "Usage: app.rb [options]"
    exit
  end

  migrator = Migrator.new
  if options[:export]
    migrator.retrieve(options)
  end

  if options[:import]
    migrator.publish(options)
  end
end