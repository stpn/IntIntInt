class Video < ActiveRecord::Base

  
  def load_video(number)
    query ||= Video.yt_session.videos_by(:view_count => number)
    @hm = String.new
    @wow = Array.new
    query.videos.each do |wow|
      @hm = wow.video_id
      @wow.push @hm
    end
    return @wow
  end

  def self.yt_session
     @yt_session ||= YouTubeIt::Client.new(:dev_key => "AI39si4iWjIA8z-kwuLxWbEfu-4WUfvzi8LxuguBvxgSl2VaUoYDj_L_J8QRBsZivSH92msVpJPUMRuRegY1mp_mh57X32Mh0g")    
   end

end
