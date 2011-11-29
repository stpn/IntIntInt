class Video < ActiveRecord::Base

  def self.load_video(number)

    query ||= Video.yt_session.videos_by(:view_count => number, :max_results => 50)
    @video_string = String.new
    @video_array = Array.new
    @keywords_array = Array.new
    @views_array = Array.new
    @id_array = Array.new
    query.videos.each do |wow|
      @video_string = wow.video_id
      @content_string = @video_string[/video:(.*)/]
      @real_video_id = $1
      @keywords_string = wow.keywords

      @video_hash  = {@real_video_id => @keywords_string}
      @video_array.push @video_hash
      @video_array.each do |hash|
        hash.each do |k,v|
          @video_find = Video.find_by_content(k)
          if !@video_find.blank?
            hash.delete k
          end
        end
      end

      end
      return @video_array
    end

    def self.load_comments(youtube_id)
      @comments_content = String.new
      @comments_array = Array.new
      comments_query ||= Video.yt_session.comments(youtube_id)
      comments_query.each do |comment|
        @comments_content = "PARSEFROMHERE " + comment.content + " ENDPARSEFROMHERE"
        matches = @comments_content.match(/\d+:\d+/)
        if !matches.nil?
          @comments_array.push @comments_content
        end

      end
      return @comments_array
    end





    def self.yt_session
      @yt_session ||= YouTubeIt::Client.new(:dev_key => "AI39si4iWjIA8z-kwuLxWbEfu-4WUfvzi8LxuguBvxgSl2VaUoYDj_L_J8QRBsZivSH92msVpJPUMRuRegY1mp_mh57X32Mh0g")
    end

  end
