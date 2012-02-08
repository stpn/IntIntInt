class PlotCreator
  @queue = :plots_queue
  def self.perform(plot_id)
    @plot = Plot.find(plot_id)
     query = @plot.name
      youtubeids = Array.new
      words = Array.new
      hash_of_search = Plot.search_youtube(query)
      #    new_hash = Plot.filter_by_sentiment(hash_of_search, query)
      #    new_hash.each do |k,v|
      #      v.split(' ').each do |f|
      hash_of_search.each do |k,v|
        match = v.match("phraseis")
        if match.nil?
          youtubeids << v
          words << k
        end
      end
      youtubeids = Plot.pull_youtubeids_with_timecodes_with_hash(youtubeids, hash_of_search)
      @plot.youtubeid = (Plot.create_youtubelinks(youtubeids))
      @plot.content = (Plot.create_iframes(youtubeids))
      @plot.chosen_word = words
      @plot.timepoint = ytids
      @plot.sentiment_value = Plot.find_sentiment_value(words)
      @plot.save
      @plot.timepoint = @plot.timepoint.gsub(/\n/,'')
      @plot.timepoint = @plot.timepoint.gsub(/-/,'')
      @plot.save
  end
end

