class Migrator

  def retrieve(options = {})
    source = Client.source

    # there is a special 'general' folder as well.
    _, sourceFolders = source.list_folders
    sourceFolders << {"id" => 0 }

    sourceFolders.map do |fl|
      # get the dashboards for each folder
      _, dashboards = source.list_dashboards(fl["id"])

      dashboards.map { |db| Storage.write(source.fetch_dashboard_body(db["id"]), fl["uid"]) }
    end
  end

  def publish(options = {})
    folders = Storage.list_local_folders

    target = Client.target

    _, target_folders = target.list_folders

    target_folders.select!{ |f| folders.include? f["uid"] }

    # now iterate over the target folders
    target_folders.each do |f|
      dashboards = Storage.list_local_dashboards(f["uid"])
      dashboards.each do |d|
        dashboard = Storage.read(d, f["uid"])

        # transformed to target - metrics service names need to be migrated
        tx = Transform.transform(dashboard)
        puts "Searching for dashboard #{tx["data"]["title"]} in #{target.server}"
        _, target_dashboard = target.search_dashboards(tx["data"]["title"])

        if target_dashboard.first
          rtid = target_dashboard.first["id"]
          puts "Found target with id #{rtid}"
          rtxb = target.fetch_dashboard_body(rtid)


          diff(tx, rtxb, options)
        else
          $stderr.puts "No target found for dashboard #{rtid} by title #{tx["data"]["title"]}"
        end
      end
    end

    # now do local general dashboards
    dashboards = Storage.list_local_dashboards('.')
    dashboards.each do |d|
      dashboard = Storage.read(d, '.')

      # transformed to target - metrics service names need to be migrated
      tx = Transform.transform(dashboard)
      puts "Searching for dashboard #{tx["data"]["title"]} in #{target.server}"
      _, target_dashboard = target.search_dashboards(tx["data"]["title"])

      if target_dashboard.first
        rtid = target_dashboard.first["id"]
        puts "Found target with id #{rtid}"
        rtxb = target.fetch_dashboard_body(rtid)

        # if options[:visual_diff]
        diff(tx, rtxb, options)
      else
        $stderr.puts "No target found for dashboard #{rtid} by title #{tx["data"]["title"]}"
      end
    end
  end

  def diff(src, tgt, options)
    # for this to work you need to patch path_segment.rb in check_please
    #
    #     def initialize(name = nil)
    #       @name = name.to_s.strip
    #
    #       case @name
    #       when ""#, /\s/ # blank or has any whitespace <-- PATCH THIS LIKE THIS TO PERMIT WHITESPACE
    #         raise InvalidPathSegment, "#{name.inspect} is not a valid #{self.class} name"
    #       end
    #
    #       parse_key_and_value
    #       freeze
    #     end
    #
    # to permit


    if options[:attempt_merge]
      diff = Transform.panel_merge(src, tgt)
    else
      diff = CheckPlease.diff(src, tgt)
    end

    if options[:visual_diff]
      puts CheckPlease::Printers.render(diff)
    else
      puts "Dashboard containts #{diff.instance_variable_get('@list').length} differences"
    end
    exit # debug
  end
end