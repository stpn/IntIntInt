class Phrase < ActiveRecord::Base

  @phraseid = 0

  belongs_to :video
  has_many :connotations
  validates_associated :connotations



  def self.build_phrases(videos)
    p videos
    @phrases = []
    result = Array.new
    videos.each do |video|
      phr = Phrase.process_single_video(video)
      if !phr.blank?
        @phrases.push phr
      end

    end
    if !@phrases.blank?
      @phrases.each do |ph|
        ph.each do |phh|
          phh = Phrase.single_phrase_to_timecode(phh)
          phh.save!
          phh = Phrase.remove_junk_single(phh)
          phh = Phrase.calculate_sentiment(phh)
          result << phh
        end
      end
    end
    return result
  end


  ###CARPET BOMBING::

  def self.load_all_comments
    Video.destroy_all "comments = '--- []\n'"
    #    videos_with_non_nil_comments = Video.find_all_by_download(true)
    videos_with_non_nil_comments = Video.find(:all, :conditions => "comments IS NOT NULL")
    videos_with_non_nil_comments.each do |video|
      phrase = Phrase.process_single_video(video)
    end
    Phrase.timecodes_to_columns
    Phrase.remove_junk
  end


  def self.timecodes_to_columns
    Phrase.all.each do |phrase|
      phrase = Phrase.single_phrase_to_timecode(phrase)
    end
  end

  def self.remove_junk
    Phrase.all.each do |phrase|
      phrase = Phrase.remove_junk_single(phrase)
    end
  end

  def self.process_single_video(video)
    result = Array.new
    comments_array = Array.new
    comments_string = video.comments
    #  if comments_string.class == Array
    comments_string.each do |c_s|
      comments_array = c_s.scan(/PARSEFROMHERE\s(.*?)\sENDPARSEFROMHERE/m)
    end

    # else
    #       comments_array = comments_string.scan(/PARSEFROMHERE\s(.*?)\sENDPARSEFROMHERE/m)
    #     end
    comments_array.each do |a|
      if a!=[]
        phrase = Phrase.create
        phrase.content = a[0]
        phrase.youtubeid = video.content
        phrase.video_id = video.id
        phrase.save!
        result << phrase
      end
    end

    return result
  end

  def self.process_multiple_videos(videos)

    result = Array.new
    @comments_array = Array.new
    videos.each do |v|

      if !v.comments.blank?
        comments_string = v.comments
        comments_string.each do |c_s|
          @comments_array = c_s.scan(/PARSEFROMHERE\s(.*?)\sENDPARSEFROMHERE/m)
        end

        @comments_array.each do |a|
          phrase = Phrase.create
          phrase.content = a
          phrase.youtubeid = v.content
          phrase.video_id = v.id
          phrase.save!
          result << phrase
        end
      end
    end

    return result
  end


  def self.single_phrase_to_timecode(phrase)
    mtch =  phrase.content.match(/(\d+:\d\d-\d+:\d\d)/)
    mtch2 =  phrase.content.match(/(\d+:\d+)/)
    if !mtch.nil?
      phrase.timecode = phrase.content.scan(/(\d+:\d\d-\d+:\d\d)/).join(' ')
      phrase.save!
    elsif !mtch2.nil?
      phrase.timecode = phrase.content.scan(/(\d+:\d+)/).join(' ')
      phrase.save!
    end
    return phrase
  end



  def self.remove_junk_single(phrase)
    parsed = phrase.content
    parsed = parsed.gsub(/(\\uFEFF)/,'')
    parsed = parsed.gsub(/(...\n-\s!..)/,'')
    parsed = parsed.gsub(/(\W\n)/,'')
    parsed = parsed.gsub(/(\n)/,'')
    parsed = parsed.gsub(/(\\n)/,'')
    parsed = parsed.gsub(/(---)/,'')
    phrase.content = parsed
    phrase.save!
    return phrase
  end


  def self.all_relevant_phrases
    phrase = Phrase.find(:all, :conditions => "rating IS NULL")
    return phrase
  end

  def add_connotation(rating)
    c = self.connotations.create(:rating => rating)
    c.save!
  end

  def self.remove_all_duplicates
    (Phrase.all - Phrase.all.uniq_by{|r| [r.content, r.youtubeid]}).each{ |d| d.destroy }
  end

  def self.calculate_sentiment_for_all
    Phrase.all.each do |p|
      p = Phrase.calculate_sentiment(p)
    end
  end

  def self.calculate_sentiment(ph)
    if ph.rating.blank?
      mtch = ph.content.match(/[a-zA-Z]/)
      if !mtch.nil?
        search = Plot.clean_search(ph.content)
        noun_phrases = Plot.select_multiples(search)
        noun_phrases = Plot.merge_multiples_and_singles(noun_phrases, search)
        #          noun_phrases = Plot.process_query(p.content)
        ph.rating = Plot.find_sentiment_value(noun_phrases)
        ph.save!
      end
    end
    return ph
  end



end
