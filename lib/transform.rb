=begin
  transforms a grafana dashboard from format 6.4.x to 7.2.x
=end
class Transform

  def self.transform(candidate)

    # transform datasource references
    candidate["data"]["panels"]&.each do |panel|
      panel["datasource"] = "Metrics" if panel["datasource"] == "Prometheus"
    end

    # transform annotation references
    candidate["data"]["annotations"]["list"]&.each do |annotation|
      annotation["datasource"] = "Metrics" if annotation["datasource"] == "Prometheus"
    end

    # transform templating references
    candidate["data"]["templating"]["list"]&.each do |annotation|
      annotation["datasource"] = "Metrics" if annotation["datasource"] == "Prometheus"
    end

    candidate
  end

  # attempt to reconcile differences between a source and target diff
  def self.panel_merge(src, target)


    diff =  CheckPlease.diff(src, target)
    list = diff.instance_variable_get('@list')
    pp list
    pp list.length

    #
    # xref = {}
    #
    # titles = list.select { |diff| diff.path.match /title$/ }
    # titles.each do |diff|
    #   # pp diff
    #   panelid = diff.path.match(/\/([0-9]+)\//)[1]
    #   srctitles[diff.reference] = panelid
    #   tgttitles[diff.candidate] = panelid
    # end
    #
    # pp target
    exit
    #rerun the diff
    CheckPlease.diff(src, target)
  end
end