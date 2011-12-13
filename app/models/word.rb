class Word < ActiveRecord::Base

  def self.load_all_words
   stop_words = %w{'parsefromhere parsefromhere endparsefromhere endparsefromhere' a u able about across after all almost also am among an and any are as at be because been but by can cannot could dear did do does either else ever every for from get got had has have he her hers him his how however i if in into is it its just least let like likely may me might most must my neither no nor not of off often on only or other our own rather said say says she should since so some than that the their them then there these they this tis to too twas us wants was we were what when where which while who whom why will with would yet you your}
    @comments_string = String.new
    Video.all.each do |video|
      if video.comments != "--- []\n"
              if !video.comments.nil?
        @comments_string << video.comments
      end
    end

    end
    @comments_string = @comments_string.downcase
    parsed = @comments_string.split.reject { |w| stop_words.include?(w.gsub(/[(\\")]/, '').downcase) }.join(' ')
    parsed = parsed.gsub(/\d:\d\d/,' ')
    parsed = parsed.gsub(/[\d]/,' ')
    parsed = parsed.gsub(/[\\"]/,' ')
    parsed = parsed.gsub(/\d\d:\d\d/,' ')
    parsed = parsed.gsub("---",' ')
    parsed = parsed.gsub(" - ",' ')
    parsed = parsed.gsub(" + ",' ')
    parsed = parsed.gsub(" = ",' ')
    parsed = parsed.gsub(/\s\,+/,' ')
    parsed = parsed.gsub(/[,]/,' ')    
    parsed = parsed.gsub(/\s\?+/,' ')
    parsed = parsed.gsub(/\s\.+/,' ')    
    parsed = parsed.gsub(/\s\!+/,' ')  
    parsed = parsed.gsub(/\s\W\s/,' ')
    parsed = parsed.gsub(/\s.\s/,' ')
    parsed = parsed.gsub(/\w\?+/,' ')
    parsed = parsed.gsub(/\s{2,}/,' ')    

    parsed = parsed.split(/ /)
    parsed = parsed.uniq
    parsed = parsed.join(" ")
    return parsed
  end

end