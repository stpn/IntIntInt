class Plot < ActiveRecord::Base
  include ParsingHelpers
  include NewThings

  serialize :chosen_word, Array
  serialize :youtubeid, Array
  serialize :content, Array

  @hypernym_storage = stringed_hash
  @hypernym_array = Array.new

  @boom = Object.new

  def self.search(search)
    @neg = Array.new
    @sorted_words = Array.new
    @result = stringed_hash
    @positive = stringed_hash

    @multiple_words = Plot.process_query(search)

    # This finds words in our metaword corpus and returns y_ids with words that are present         !!!! STOPWORD CHECKING!!
    @multiple_words.each do |w|
      mtch = w.match(/\s/)
      if mtch.nil?
        if !stop_words.include?(w)
          cont = Metaword.find_by_content(w)
          if !cont.nil?
            mtch = @positive[w].match(/#{cont.youtubeid}/)
            if mtch.nil?
              cont.videos.each do |cv|
                @positive[w] << "#{cv.content} "
              end
            end
          else
            @neg << w
          end
        end
      end
    end

    @neg = @neg.join(' ').split(' ').uniq
    @neg = remove_stop_words(@neg)

    @neg_to_pos = Plot.build_pos_hash(@parts_of_speech, @neg)

    Plot.start_hypernymation(@neg_to_pos, 0)

    @positive = @positive.merge(Plot.hypernyms_to_metawords)

    @positive.each do |k,v|
      @sorted_words << k
    end

    # Sort the words according to init string
    @sorted_words = @sorted_words.sort_by { |substr| Plot.clean_search(search).index(substr) }
    @sorted_words.each do |s|
      @positive[s].split(' ').each do |b|
        @result[s] << "#{b} "
      end
    end
    @boom = @positive
    #   return @result
    return @boom
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
    return @search
  end

  ##########Process queries##################################
  ###########################################################


  def self.process_query(query)
    @search = Plot.clean_search(query)
    @multiple_words = Array.new
    @single_words = Array.new

    tgr = EngTagger.new
    @tagged = tgr.add_tags(@search)
    @tagged_phrases = tgr.get_noun_phrases(@tagged)

    @single_words = @search.gsub(/[\?\!\.]/,'')
    @single_words = @single_words.gsub(/('\w)/,'').split(' ').uniq
    @parts_of_speech ||= Plot.convert_to_pos(@tagged)

    # This is creation of the array with unique words
    @tagged_phrases.each do |k,v|
      mtch = k.match(/\s/)
      if !mtch.nil?
        @multiple_words << k.gsub(/[\?\!\.]/,'')
      end
    end

    @multiple_words = Plot.remove_multiple_word_duplicates(@multiple_words)

    #better to create another object?
    @single_words.each do |word|
      b = @multiple_words.join(' ').include? word
      if b==false
        @multiple_words << word
      end
    end

    #Now create a string without the matched words
    @q2 = @search
    remove_stop_words(@multiple_words).each do |a|
      @q2 = @q2.gsub(/#{a}'\w/,'')
      @q2 = @q2.gsub(/#{a}/,'')
    end

    # remove the stop_words and return a clean array
    @q2.split(' ').each do |q|
      @multiple_words << q
    end

    return @multiple_words.uniq

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




  ########POS CONVERTING#########
  ##############################
  def self.convert_to_pos(tagged_by_engtagger)
    @verbs = Array.new
    @nouns = Array.new
    @adverbs = Array.new
    @adjs = Array.new
    @adj_string =  %w{jj jjr jjs}
    @noun_string = %w{nn nnp nnps}
    @adverb_string = %w{rb rbr rbs rp}
    @verb_string = %w{md vb vbd vbg vbn vbp vbz}

    # Parse parts of speech
    doc = Nokogiri::XML('<xml>'+tagged_by_engtagger+'</xml>')
    @parts_of_speech = doc.xpath('/xml').map do |i|
      {'jj' => i.xpath('jj').collect(&:text),
       'jjr' => i.xpath('jjr').collect(&:text),
       'jjs' => i.xpath('jjs').collect(&:text),

       'nn' => i.xpath('nn').collect(&:text),
       'nnp' => i.xpath('nnp').collect(&:text),
       'nnps' => i.xpath('nnps').collect(&:text),

       'rb' => i.xpath('rb').collect(&:text),
       'rbr' => i.xpath('rbr').collect(&:text),
       'rbs' => i.xpath('rbs').collect(&:text),
       'rp' => i.xpath('rp').collect(&:text),

       'md' => i.xpath('md').collect(&:text),
       'vb' => i.xpath('vb').collect(&:text),
       'vbd' => i.xpath('vbd').collect(&:text),
       'vbg' => i.xpath('vbg').collect(&:text),
       'vbn' => i.xpath('vbn').collect(&:text),
       'vbp' => i.xpath('vbp').collect(&:text),
       'vbz' => i.xpath('vbz').collect(&:text)
       }
    end

    @parts_of_speech.each do |i|
      i.each do |k,v|
        if v.empty?
          i.delete(k)
        end
      end
    end

    #Fill array of parts of speech
    @parts_of_speech.each do |i|
      i.each do |k,v|
        if @verb_string.include?(k)
          @verbs << v
        elsif @adj_string.include?(k)
          @adjs << v
        elsif @adverb_string.include?(k)
          @adverbs << v
        elsif @noun_string.include?(k)
          @nouns << v
        end
      end
    end

    @verbs = @verbs.join(' ').split(' ')
    @adjs = @adjs.join(' ').split(' ')
    @adverbs = @adverbs.join(' ').split(' ')
    @nouns = @nouns.join(' ').split(' ')
    @new_parts = {"verbs" => @verbs, "adjs" => @adjs, "adverbs" => @adverbs, "nouns" => @nouns}
    return @new_parts

  end

  def self.build_pos_hash(parts_of_speech, neg)
    #Creating hash of parts of speech
    neg_to_pos = stringed_hash
    parts_of_speech.each do |k,v|
      if k == "verbs"
        neg_to_pos["verbs"] << (neg & v).uniq.join(' ')
      elsif k == "adjs"
        neg_to_pos['adjs'] << (neg & v).uniq.join(' ')
      elsif k == "nouns"
        neg_to_pos['nouns'] << (neg & v).uniq.join(' ')
      elsif k == "adverbs"
        neg_to_pos['adverbs'] << (neg & v).uniq.join(' ')
      end
    end

    return neg_to_pos
  end

  ##########Collect Youtube_ids for found hypernyms###########
  ###########################################################

  def self.hypernyms_to_metawords
    temp_arr = Array.new
    hypernym_youtubeids = stringed_hash
    @hypernym_storage.each do |k,v|
      v.split(',').each do |word|
        #Still have to decide whether to add the stopword checking:: ADDED
        mtch = word.match(/\s/)
        if mtch.nil?
          if !stop_words.include?(word)
            metaword_matches = Metaword.find_all_by_content(word)
            metaword_matches.each do |m|
              m.videos.each do |mw|
                temp_arr << mw.content # + " #{m.content}"
              end
              temp_arr = temp_arr.uniq
              temp_arr.each do |t|
                hypernym_youtubeids[k] << "#{t} "
              end
              temp_arr = temp_arr.clear
            end
          end
        end
      end
    end
    return hypernym_youtubeids
  end

  ########FIND HYPERNYMS#########
  ##############################
  def self.start_hypernymation(neg_to_pos, counter)
    if counter == 0
      Plot.process_neg_to_pos('verbs', neg_to_pos['verbs'], counter, neg_to_pos)
    elsif counter == 1
      Plot.process_neg_to_pos('adjs', neg_to_pos['adjs'], counter, neg_to_pos)
    elsif counter == 2
      Plot.process_neg_to_pos('adverbs', neg_to_pos['adverbs'], counter, neg_to_pos)
    elsif counter == 3
      Plot.process_neg_to_pos('nouns', neg_to_pos['nouns'], counter, neg_to_pos)
      @hypernym_storage.delete_if{|k,v| v == "" }
    end

  end


  def self.process_neg_to_pos(pos, words, counter, neg_to_pos)
    words = words.split(' ')

    words.each do |v|
      @hypernym_storage[v] << Plot.find_hypernyms(pos, v)
    end
    counter = counter + 1
    p counter
    Plot.start_hypernymation(neg_to_pos, counter)
  end




  def self.find_hypernyms(pos, word)
    p word
    p pos
    #This is a hypernym extractor
    if pos == 'nouns'
      index = WordNet::NounIndex.instance
    end
    if pos == 'adjs'
      index = WordNet::AdjectiveIndex.instance
    end
    if pos == 'adverbs'
      index = WordNet::AdverbIndex.instance
    end
    if pos == 'verbs'
      index = WordNet::VerbIndex.instance
    end
    @hypers = Array.new
    str = Array.new
    lemma = index.find(word.downcase)
    if !lemma.nil?
      lemma.synsets.each do |synset|
        synset.expanded_hypernym.each do |s|
          str = s.to_s.scan(/\(\w\)\s(.*?)\s\(.*?\)/m)
          str.each do |s|
            @hypers << s
          end
        end
      end
    end
    return @hypers.join(', ')

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
    ####
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

  def self.find_closest_phrase(array_of_phrases, target_word)
    result = 0
    closer_num = 0
    target_number = Plot.find_sentiment_value(target_word)
    if !array_of_phrases.nil?
      hash_of_ratings = Hash.new{|h,k| h[k] = []}
      array_of_ratings = Array.new
      array_of_phrases.each do |ph|
        if !ph.rating.blank?
          hash_of_ratings[ph.rating] = ph
          array_of_ratings << ph.rating
        end
      end
      if !array_of_ratings.blank?
        closer_num = Plot.find_closest_number(array_of_ratings, target_number)
        result = hash_of_ratings[closer_num]
      end
    end
    return result
  end

  #######FIND CLOSEST NUMBER, APP-AGNOSTIC

  def self.find_closest_number(array_of_numbers, target_number)
    closer_num = 0.0001
    if !array_of_numbers.blank?
      if array_of_numbers.length == 1
        closer_num = array_of_numbers[0]
      else
        ary = array_of_numbers.partition do |elmt|
          elmt < target_number
        end
        lowest = ary[0].max
        highest = ary[1].min
        if lowest.nil?
          closer_num = highest
        elsif highest.nil?
          closer_num = lowest
        elsif (highest - target_number > target_number - lowest)
          closer_num = highest
        else
          closer_num = lowest
        end
      end
    end
    return closer_num
  end

  ##############QUERY PROCESSING:
  # SWITCHES WORD FOR HASH WITH VALUES
  ###############################
  #
  # def self.filter_query_by_sentiment(query, search_hash)
  #   query_hash = stringed_hash
  #   query_array = Plot.process_query(query)
  #   search_hash.each do |k,v|
  #     query_array.each do |q|
  #       if q.include?(k)
  #
  #
  #         query_hash[k] << q
  #       end
  #     end
  #   end
  #   result = Plot.new_sentiment_values(query_hash)
  #   return result
  # end
  #
  #
  # def self.new_sentiment_values(query_hash)
  #   result = Hash.new{|h,k| h[k] = 0 }
  #   query_hash.each do |k, v|
  #     new_sentiment = Plot.find_sentiment_value(v)
  #     result[k] << new_sentiment
  #   end
  #   return result
  # end
  # ######

  def self.swap_words_for_multiples(search_hash, query)
    query_hash = stringed_hash
    query_array = Plot.process_query(query)
    search_hash.each do |k,v|
      query_array.each do |q|
        if q.include?(k)
          query_hash[q] << v
        end
      end
    end
    result = query_hash
    return result
  end

  def self.swap_multiples_for_single(processed_search, search_hash)
    result = stringed_hash
    search_hash.each do |k, v|
      processed_search.each do |c, w|
        if c.include?(k)
          result[k] << w
        end
      end
    end

    return result

  end


end
