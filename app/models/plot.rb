class Plot < ActiveRecord::Base
  include ParsingHelpers
  include NewThings

  #  serialize :chosen_word, Array
  #  serialize :youtubeid, Array
  #  serialize :content, Array

  @boom = Object.new


  def search_galaxy
    result = Hash.new
#    if self.galaxy == 'youtube'
    result = Plot.search_youtube(self.name)
 #   elsif self.galaxy == 'vimeo'
   #   result = Plot.search_vimeo(self.name)
  #  end
    return result
  end

  def self.search_vimeo(query)
    @sorted_words = Array.new
    result = stringed_hash
    video_hash = Hash.new{|h,k| h[k] = nil }
    @search = Plot.clean_search(query)
    phrases = []
    multiple_words = @search.split(' ')
   end
  #####THIS IS FOR JUST ONE KEYWORD


  def self.search_youtube(query)
    @sorted_words = Array.new
    result = stringed_hash
    video_hash = Hash.new{|h,k| h[k] = nil }
    @search = Plot.clean_search(query)
    phrases = []
    multiple_words = @search.split(' ')
    # This finds words in our metaword corpus and returns y_ids with words that are present         !!!! STOPWORD CHECKING!!
    multiple_words.each do |w|
      #     mtch = w.match(/\s/)
      #      if mtch.nil?
        @videos = Plot.collect_videos(w, 1, 1)
        if !@videos.blank?
          video_hash[w] = @videos
        end
 #     end
    end
    video_hash.each do |k,v|
      if !v.blank?
        phrases = Phrase.build_phrases(v)
        if !phrases.blank?
          closest_phrase = Plot.find_closest_phrase(phrases, k)
          result[k] << closest_phrase.video.content
          result[closest_phrase.video.content] << "phraseis #{closest_phrase.id}"
        end
      end
    end
    #   end
    p "#{result}  <<<<<<<<< RESULT"
    return result
  end


  def self.collect_videos(w, page, indexing)
    print "WORD IS :" + w
    ticker = 0
    word = w 
    videos = []
    query = Video.yt_session.videos_by(:categories => [w.parameterize.to_sym], :max_results => 25, :page => page, :index => indexing, :per_page => 25) 
    query.videos.each do |vid|
      if vid.noembed == false
        ticker = ticker+1
      end
    end
    if ticker < 20
      Plot.collect_videos(word, page+1, indexing+25)
    end
    video_array = Video.pull_videos_from_youtube(query, video_array)
    print video_array
    if !video_array.empty?
      video_array.each do |hash|
        hash.each do |k,v|
          comments = Video.load_comments(k)
          if comments != "--- []\n"
            vid = Video.create
            vid.content  = k
            vid.keywords = v
            vid.comments = comments
            vid.save!
            #            (:content => k, :keywords => v, :comments => comments )
            videos << vid
          end
        end
      end
    else
       videos = videos + Plot.collect_videos(word ,page+1, indexing+25)
     end
     if videos.blank?
       videos = videos + Plot.collect_videos(word ,page+1, indexing+25)
     else
    return videos
  end
  end



  ##########Clean search##################################
  ###########################################################

  def self.clean_search(query)
    @search = query.gsub(/[\.,;:\-{}\[\]()\d]/, ' ').downcase
    #think if you need this extreme:
    @search = @search.gsub(/[^a-zA-Z]/, ' ').downcase
    @search = @search.gsub(/\n/, ' ').downcase
    @search = @search.gsub(/\d{2,}/, ' ').downcase
    @search = @search.gsub(/\s{2,}/, ' ').downcase
    @search = @search.gsub(/\\/, '').downcase
    search = @search.split(' ')
    search.each do |w|
      if stop_words.include?(w)
        search.delete(w)
        print w + ' '
      end
    end
    search = search.join(' ')
    print search
    return search
  end

  ##########Process queries##################################
  ###########################################################



  def self.select_multiples(search)
    multiple_words = Array.new
    tagged_phrases = Plot.tag_phrases(search)
    # This is creation of the array with unique words
    tagged_phrases.each do |k,v|
      mtch = k.match(/\s/)
      if !mtch.nil?
        multiple_words << k.gsub(/[\?\!\.]/,'')
      end
    end
    multiple_words = Plot.remove_multiple_word_duplicates(multiple_words)
    result = multiple_words
    return result
  end

  def self.select_single(search)
    multiple_words = Array.new
    tagged_words = Plot.tag_words(search)
    # This is creation of the array with unique words

    # tagged_words = Plot.remove_multiple_word_duplicates(tagged_words)
    result = tagged_words
    return result
  end


  def self.tag_phrases(search)
    tgr = EngTagger.new
    tagged = tgr.add_tags(search)
    tagged_phrases = tgr.get_noun_phrases(tagged)
    result = tagged_phrases
    return result
  end

  def self.tag_words(search)
    tgr = EngTagger.new
    tagged = tgr.add_tags(search)
    tagged_phrases = tgr.get_nouns(tagged)
    result = tagged_phrases
    return result
  end

  def self.tag_query(search)
    tgr = EngTagger.new
    tagged = tgr.add_tags(search)
    result = tagged
    return result
  end

  def self.merge_multiples_and_singles(multiple_words, search)
    single_words = Array.new
    single_words = search.gsub(/[\?\!\.]/,'')
    single_words = single_words.gsub(/('\w)/,'').split(' ').uniq
    #better to create another object?
    single_words.each do |word|
      b = multiple_words.join(' ').include? word
      if b==false
        multiple_words << word
      end
    end
    #Now create a string without the matched words
    q2 = search
    remove_stop_words(multiple_words).each do |a|
      q2 = q2.gsub(/#{a}'\w/,'')
      q2 = q2.gsub(/#{a}/,'')
    end
    # remove the stop_words and return a clean array
    q2.split(' ').each do |q|
      multiple_words << q
    end
    result = multiple_words.uniq
    return result
  end


  #########CLEANS NOUN PHRASES FROM REPEATED WORDS######
  #####################################################

  def self.remove_multiple_word_duplicates(multiple_words_array)
    temp_arr = Array.new
    multiple_words2 = multiple_words_array
    multiple_words_array.each do |mw|
      multiple_words2.each do |bb|
        if mw!=bb
          b = bb.include? mw
          if b == true
            #CHANGE TO MAKE RESULTING PHRASES LONGER:
            # temp_arr << mw
            temp_arr << bb
          end
        end
      end
    end
    result = multiple_words_array - temp_arr
  end





  #######Create HTMLs############
  ##############################

  def self.pull_youtubeids_with_timecodes(ytids)
    result = Array.new
    ytids.each do |y|
      timecode = Phrase.find_by_youtubeid(y).timecode
      mtch2 = timecode.match(/(\d+:\d\d)/)
      if !mtch2.nil?
        # mtch = timecode.match(/(\d+:\d\d-\d+:\d\d)/)
        #        if !mtch.nil?
        #          timecode = timecode.scan(/(\d+:\d\d)-\d+:\d\d/).join(' ')
        #          timecode = timecode[/(\d+):(\d\d)/]
        #          timecode = '#t='+$1+'m'+$2+'s'
        #        else
        timecode = timecode[/(\d+):(\d\d)/]
        timecode = '#t='+$1+'m'+$2+'s'
      end
      result << "#{y}#{timecode}"
      #        end
    end
    return result
  end


  def self.pull_youtubeids_with_timecodes_with_hash(ytids, search_hash)
    result = Array.new
    search_hash.each do |k, v|
      ytids.each do |y|
        if y == k
          phrase = v[/phraseis\s(.*)/]
          timecode = Phrase.find_by_id($1).timecode
          mtch2 = timecode.match(/(\d+:\d\d)/)
          if !mtch2.nil?
            # mtch = timecode.match(/(\d+:\d\d-\d+:\d\d)/)
            #        if !mtch.nil?
            #          timecode = timecode.scan(/(\d+:\d\d)-\d+:\d\d/).join(' ')
            #          timecode = timecode[/(\d+):(\d\d)/]
            #          timecode = '#t='+$1+'m'+$2+'s'
            #        else
            timecode = timecode[/(\d+):(\d\d)/]
            a = $1
            b = $2
            if a == "0"
              if b == "00"
                b = "01"
              end
            end
            timecode = '#t='+a+'m'+b+'s'
            result << "#{y}#{timecode}"
          else
            timecode = '#t=0m01s'
            result << "#{y}#{timecode}"
          end
        end
      end
    end
    return result
  end






  def self.create_iframes(ytids)
    result = Array.new
    ytids.each do |y|
      result << "<iframe width='320' height='200' src= http://www.youtube.com/embed/#{y}   frameborder='0' ></iframe>"
    end
    return result
  end

  def self.create_youtubelinks(ytids)
    result = Array.new
    ytids.each do |y|
      result << "http://www.youtube.com/watch?v=#{y}"
    end
    return result
  end

  ##########Check sentiment value of phrase by comparing with words#######
  ########################################################################
  #The general logic is to assign 0.0001 when the word is not found in the sentiment lookup table
  #

  def self.find_sentiment_value(comment)
    found_value = false
    rating = 0
    ###NOT THE BEST RESCUE::
    if comment.class == String
      comment = comment.split(' ')
    end
    comment.each do |w|
      mtch = w.match(/\s/)
      if !mtch.nil?
        w = w.split(' ')
        w.each do |ww|
          found_in_sentiment = Word.find_by_content(ww)
          if !found_in_sentiment.nil?
            found_value = true
            rating = rating + found_in_sentiment.rating
          end
        end
      else
        found_in_sentiment = Word.find_by_content(w)
        if !found_in_sentiment.nil?
          found_value = true
          rating  = rating + found_in_sentiment.rating
        end
      end
    end
    if found_value == true
      result = rating
    else
      result = 0.0001
    end
    return result
  end

  #####FILTERING SENTIMENTS:
  #########################
  def self.filter_by_sentiment(search_hash, query)
    processed_search = stringed_hash
    hash_to_process = Plot.swap_words_for_multiples(search_hash, query)
    hash_to_process.each do |k,v|
      correct_video = Plot.find_correct_video(v, k)
      processed_search[k] << correct_video
    end
    result = Plot.swap_multiples_for_single(processed_search, search_hash)
    return result
  end


  def self.swap_words_for_multiples(search_hash, query)
    search = Plot.clean_search(query)
    added_multiples = stringed_hash
    multiple_words = Plot.select_multiples(search)
    search_hash.each do |k,v|
      multiple_words.each do |q|
        mtch = q.match(/(\A|\b)#{k}(\b|\z)/)
        if !mtch.nil?
          added_multiples[q] << v
          search_hash.delete_if{|a,b| b == v }
        end
      end
    end
    search_hash = search_hash.merge(added_multiples)
    result = search_hash
    return result
  end


  def self.swap_multiples_for_single(processed_search, search_hash)
    result = stringed_hash
    search_hash.each do |k, v|
      processed_search.each do |c, w|
        if c.include?(k)
          result[k] << "#{w} "
        end
      end
    end
    return result
  end


  def self.find_correct_video(ytids_string, target_word)
    yt_phrases_hash = Hash.new{|h,k| h[k] = [] }
    array_of_ratings = Array.new
    ytids_string.split(' ').each do |yt|

      y = Video.find_by_content(yt)
      closest_phrase = Plot.find_closest_phrase(y.phrases, target_word)
      yt_phrases_hash[yt] = closest_phrase

    end
    closest_yt = Plot.find_closest_yt(yt_phrases_hash, target_word)
    result = closest_yt
    return result
  end


  def self.find_closest_yt(yt_phrases_hash, target_word)
    result = String.new
    phr_ary = Array.new
    yt_phrases_hash.each do |k,v|
      phr_ary << v
    end
    chosen_phrase = Plot.find_closest_phrase(phr_ary, target_word)
    yt_phrases_hash.each do |k, v|
      if v == chosen_phrase
        result = k
      end
    end
    return result
  end

  #######FIND CLOSEST PHRASE:
  #### THIS SOMEHOW RETURNS 0 IF array_of_phrases CONTAINS ONLY ONE PHRASE
  def self.find_closest_phrase(array_of_phrases, target_word)
    result = 0
    closer_num = 0
    target_number = Plot.find_sentiment_value(target_word)
    if !array_of_phrases.nil?
      hash_of_ratings = Hash.new{|h,k| h[k] = []}
      array_of_ratings = Array.new
      array_of_phrases.each do |ph|
        if !ph.rating.nil?
          hash_of_ratings[ph.rating] = ph
          array_of_ratings << ph.rating
        end
      end
      if !array_of_ratings.blank?
        closer_num = find_closest_number(array_of_ratings, target_number)
        result = hash_of_ratings[closer_num]
      else
        result = array_of_phrases[rand(array_of_phrases.length)]
      end
    end
    return result
  end

end
