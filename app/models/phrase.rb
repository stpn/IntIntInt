class Phrase < ActiveRecord::Base

  @phraseid = 0

  belongs_to :video
  has_many :connotations
  validates_associated :connotations

  def self.load_all_comments
    comments_array = Array.new
    Video.destroy_all "comments = '--- []\n'"
    #    videos_with_non_nil_comments = Video.find_all_by_download(true)
    videos_with_non_nil_comments = Video.find(:all, :conditions => "comments IS NOT NULL")
    videos_with_non_nil_comments.each do |video|
      comments_string = video.comments
      comments_array = comments_string.scan(/PARSEFROMHERE\s(.*?)\sENDPARSEFROMHERE/m)
      comments_array.each do |a|
        phrase = Phrase.create
        phrase.content = a
        phrase.youtubeid = video.content
        phrase.video_id = video.id
        phrase.save!
      end
    end
    Phrase.timecodes_to_columns
    Phrase.remove_junk
  end


  def self.timecodes_to_columns
    Phrase.all.each do |phrase|
      mtch =  phrase.content.match(/(\d+:\d\d-\d+:\d\d)/)
      mtch2 =  phrase.content.match(/(\d+:\d+)/)
      if !mtch.nil?
        phrase.timecode = phrase.content.scan(/(\d+:\d\d-\d+:\d\d)/).join(' ')
        phrase.save!
      elsif !mtch2.nil?
        phrase.timecode = phrase.content.scan(/(\d+:\d+)/).join(' ')
        phrase.save!
      end
    end
  end

  def self.all_relevant_phrases
    phrase = Phrase.find(:all, :conditions => "rating IS NULL")
    return phrase
  end

  def self.remove_junk
    Phrase.all.each do |phrase|
      parsed = phrase.content
      parsed = parsed.gsub(/(\\uFEFF)/,'')
      parsed = parsed.gsub(/(...\n-\s!..)/,'')
      parsed = parsed.gsub(/(\W\n)/,'')
      parsed = parsed.gsub(/(\n)/,'')
      parsed = parsed.gsub(/(\\n)/,'')
      parsed = parsed.gsub(/(---)/,'')
      phrase.content = parsed
      phrase.save!
    end
  end

  def add_connotation(rating)
    c = self.connotations.create(:rating => rating)
    c.save!
  end

  def self.remove_all_duplicates
    (Phrase.all - Phrase.all.uniq_by{|r| [r.content, r.youtubeid]}).each{ |d| d.destroy }
  end

  def self.calculate_sentiment
    Phrase.all.each do |p|
      if p.rating.blank?
        mtch = p.content.match(/[a-zA-Z]/)
        if !mtch.nil?
          search = Plot.clean_search(p.content)
          noun_phrases = Plot.select_multiples(search)
          noun_phrases = Plot.merge_multiples_and_singles(noun_phrases, search)          
#          noun_phrases = Plot.process_query(p.content)
          p.rating = Plot.find_sentiment_value(noun_phrases)
          p.save!
        end
      end
    end
  end


end
