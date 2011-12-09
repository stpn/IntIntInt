class Phrase < ActiveRecord::Base

belongs_to :video

def self.load_all_comments
    Video.destroy_all "comments = '--- []\n'"
     videos_with_non_nil_comments = Video.find(:all, :conditions => "comments IS NOT NULL")
     videos_with_non_nil_comments.each do |video|
       if video.comments != "--- []\n"
         phrase = Phrase.create
         phrase.content = video.comments
         phrase.youtubeid = video.content
         phrase.video_id = video.id
         phrase.save!
       end
     end
     Phrase.all.each do |phrase|
       comments_array = phrase.content.scan(/\sPARSEFROMHERE\s(.*?)\sENDPARSEFROMHERE\b/m)
       comments_array.each do |a|
         ph = Phrase.create!
         ph.content = a
         ph.video_id = phrase.video_id
         ph.youtubeid = phrase.youtubeid
         ph.save!
       end
       phrase.destroy
     end
     Phrase.timecodes_to_columns
   end
   
   def self.timecodes_to_columns
       Word.all.each do |word|
         @content_string = word.content.scan(/(\d+:\d+)/)
         @content_string.each do |c|
           if word.timecode.nil? 
             word.timecode = c.to_s
           else
             word.timecode += c.to_s
           end
         end
         word.save!
       end
     end
     
    def self.all_relevant_phrases
      phrase = Phrase.find(:all, :conditions => "rating IS NULL")
      return phrase 
    end

end
