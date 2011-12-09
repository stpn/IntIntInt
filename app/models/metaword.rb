class Metaword < ActiveRecord::Base

  has_many :memberships
  has_many :videos, :through => :memberships

  def self.load_all_keywords
    Video.destroy_all "comments = '--- []\n'"
    videos_with_non_nil_comments = Video.find(:all, :conditions => "comments IS NOT NULL")
    videos_with_non_nil_comments.each do |v|
      if !v.keywords.nil?
        kw = v.keywords.split("\n- ")
        kw.delete("---")
        kw.each do |k|
          k = k.gsub(/\n/,'')
          k = k.gsub(/'/,'')
          k = k.downcase
          kwd = Metaword.find_by_content(k)          
          if kwd.nil?
            mw = Metaword.create!
            mw.content = k
            mw.youtubeid = v.content
            mw.videos << v
            mw.save!
          else
            kwd.youtubeid << v.content
            kwd.videos << v
            kwd.save!
          end
        end
      end
    end
    # Metaword.all.each do |m|
    #   redundant_array = Array.new
    #   redundant_array = Metaword.find_all_by_content(m.content)
    #   redundant_array.delete(m)
    #   redundant_array.each do |r|
    #     m.videos += r.videos
    #     m.youtubeid += r.youtubeid
    #     Metaword.find_all_by_content(r.content).destroy
    #     m.save!
    #   end
    # end
  end


end
