class Plot < ActiveRecord::Base

  @hypernym_storage = Hash.new {|h,k| h[k] = "" }
  @hypernym_array = Array.new
    @stop_words = %w{a u able about across after all almost also am
       among an and any are as at be because been but by can cannot 
       could dear did do does either else ever every for from get got 
         had has have he her hers him his how however i if in into is 
         it its just least let like likely may me might most must my 
         neither no nor not of off often on only or other our own rather re 
         said say says she should since so some than that the their them 
         then there these they this tis to too twas us wants was we were 
         what when where which while who whom why will with would yet you your a b c d e f g h i j k l m n o p q r s t u v w x y z}

  def self.search(search)
  
    @search = search.gsub(/[,;:\-{}\[\]()]/, ' ')
    @multiple_words = Array.new
    @single_words = Array.new        
    @neg = Array.new
    @sorted_words = Array.new
    @result = Array.new
    
    @positive = Hash.new{|h,k| h[k] = "" } 
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

    @single_words.each do |word| 
      b = @multiple_words.join(' ').include? word 
      if b==false 
        @multiple_words << word
      end
    end

#Now create a string without the matched words
    @q2 = @search     
     @multiple_words.each do |a|
        @q2 = @q2.gsub(/#{a}'\w/,'')
        @q2 = @q2.gsub(/#{a}/,'')                
    end
        
# remove the stop_words and return a clean @a1 array    
    @q2_parsed = @q2.split.reject { |w| @stop_words.include?(w.gsub(/[\.,;:\-{}\[\]()]/, '').downcase) }
    @q2_parsed.each do |q|
      @multiple_words << q
    end
    
 # This finds words in our metaword corpus and returns y_ids with words that are present         !!!! ADDED STOPWORD CHECKING!!
    @multiple_words.each do |w|
      mtch = w.match(/\s/)
      if mtch.nil?
      if !@stop_words.include?(w)
         cont = Metaword.find_by_content(w)
         p cont
         if !cont.blank?
         @positive[w] << "#{cont.youtubeid} "
       else 
         @neg << w
       end
     end
   end
     end
      
    @neg = @neg.join(' ').split(' ').uniq  

    @neg_to_pos = Plot.build_pos_hash(@parts_of_speech, @neg)
    Plot.start_hypernymation(@neg_to_pos, 0)


    @positive = @positive.merge(Plot.hypernyms_to_metawords)
    
    
    @positive.each do |k,v|
      @sorted_words << k
    end 

#Sort the words according to init string       
    @sorted_words = @sorted_words.sort_by { |substr| @search.index(substr) }
    
    @sorted_words.each do |s|
      @positive[s].split(' ').each do |b|
      @result << "#{b}"
    end
    end
    return @result
      
  end 



#Collect Youtube_ids for found hypernyms       
  def self.hypernyms_to_metawords
    temp_arr = Array.new
    hypernym_youtubeids = Hash.new {|h,k| h[k] = "" }
    @hypernym_storage.each do |k,v|
      v.split(',').each do |word|
        
#Still have to decide whether to add the stopword checking:: ADDED
        mtch = word.match(/\s/)
        if mtch.nil?
        if !@stop_words.include?(word)
        metaword_matches = Metaword.find_all_by_content(word)        
        metaword_matches.each do |m|
          temp_arr << m.youtubeid # + " #{m.content}"
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
    elsif counter == 4
    end
    @hypernym_storage.delete_if{|k,v| v == "" }
        
  end
    
      
  def self.process_neg_to_pos(pos, words, counter, neg_to_pos)
    words = words.split(' ')
    p words
    words.each do |v|
        @hypernym_storage[v] << Plot.find_hypernyms(pos,v)
      end
        counter = counter + 1  
        p counter      
        Plot.start_hypernymation(neg_to_pos, counter)
  end


      
      
   def self.find_hypernyms(pos, word)    
     p pos  
  #This is a hypernym extractor  
     if pos == 'nouns'    
      index = WordNet::NounIndex.instance   
      elsif pos == 'adjs'
      index = WordNet::AdjectiveIndex.instance
      elsif pos == 'adverbs'
      index = WordNet::AdverbIndex.instance
      elsif pos == 'verbs'
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
         @convert_to_pos ||= @new_parts

     end 

       def self.build_pos_hash(parts_of_speech, neg)
     #Creating hash of parts of speech
       neg_to_pos = Hash.new {|h,k| h[k] = "" }
       parts_of_speech.each do |k,v|
         if k == "verbs"
           neg_to_pos ['verbs'] << (neg & v).uniq.join(' ')
         elsif k == "adjs"
           neg_to_pos ['adjs'] << (neg & v).uniq.join(' ')
         elsif k == "nouns"
           neg_to_pos['nouns'] << (neg & v).uniq.join(' ')
         elsif k == "adverbs"
           neg_to_pos ['adverbs'] << (neg & v).uniq.join(' ')
         end
       end
       return neg_to_pos
     end
     
##############################
##############################     
   
   def self.create_iframes(ytids)
     ytids = ytids.split(', ')
     result = Array.new
     ytids.each do |y|
   result << "<iframe width='320' height='200' src= http://www.youtube.com/embed/#{y}   frameborder='0' ></iframe>"
 end
 return result
 end
 
 
  def self.create_youtubelinks(ytids)
    result = Array.new
    ytids = ytids.split(', ')
    ytids.each do |y|
      result << "<http://www.youtube.com/watch?v=#{y}"
    end
    return result
  end

end
