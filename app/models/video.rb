class Video < ActiveRecord::Base
  attr_accessor :video_array

  has_many :phrases

  has_many :memberships
  has_many :metawords, :through => :memberships

  


  def self.load_video(number, page, indexing)
    @page = number
    @number = page
    @indexing = indexing
    puts "AUV Project, page equals "+ page.to_s
    puts "AUV Project, views equals "+ number.to_s
    if @video_array.nil?
      @video_array = Array.new
    end
    query ||= Video.yt_session.videos_by(:view_count => number, :max_results => 50, :page => page, :index => indexing, :per_page => 50)
    @video_string = String.new
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
    end
    @video_array.each do |hash|
      hash.each do |k, v|
        @video_find = Video.find_by_content(k)
        if @video_find.blank?
          hash.delete(k)
        end
      end
    end
    @video_array.delete_if{|h| h.empty?}
    if !@video_array.empty?
      @video_array.each do |hash|
        hash.each do |k,v|
          @video = Video.create(:content => k, :keywords => v )
          # @video.comments = Video.load_comments(k)
          @video.save!
        end
      end
    end
    if page < 19
      sleep(60)
      Video.load_video(number, page+1, indexing+50)
    else
      sleep(180)
      Video.load_video(number+5000, 1, 1)
    end
  end


  def self.load_comments(youtube_id)
    sleep(10)
    @comments_content = String.new
    @comments_array = Array.new
    comments_query ||= Video.yt_session.comments(youtube_id) || ["something", "something"]
    #  rescue
    #    if (@page < 19)
    #    Video.load_video(@number, @page+1, @indexing+50)
    #  else
    #        Video.load_video(@number+5000, 1, 1)
    #      end
    # else
    comments_query.each do |comment|
      @comments_content = "PARSEFROMHERE " + comment.content + " ENDPARSEFROMHERE"
      matches = @comments_content.match(/\d+:\d+/)
      if !matches.nil?
        @comments_array.push @comments_content
      end
    end
    return @comments_array
  end

  def loop_through_videos
    y_ids = Array.new
    ActiveRecord::Base.uncached do
      Video.find_each do |v|
        if v.comments.nil?
          y_ids << v.content
        end
      end
    end
  end

  def self.collect_ids_for_download
    @y_ids = Array.new
    Phrase.all.each do |ph|
      if !ph.youtubeid.nil?
        @y_ids << ph.youtubeid
        video = Video.find_by_content(ph.youtubeid)
        video.download = true
        video.save!
      end
    end
    @y_ids = @y_ids.uniq
    return @y_ids
  end

  def self.collect_videos
    @y_ids = Video.collect_ids_for_download
    @y_ids.each do |v|
      dl_string = "http://www.youtube.com/watch?v="+v
      %x[cd /Users/stepanboltalin/Documents/Rails/Intel/IntIntInt_front/public/videos && exec /Users/stepanboltalin/.rvm/gems/ruby-1.9.3-p0/gems/viddl-rb-0.5.5/bin/viddl-rb http://www.youtube.com/watch?v=#\{dl_string\}]
      sleep(20)
    end
  end












  def self.yt_session
    @yt_session ||= YouTubeIt::Client.new( :username => "auvproj@gmail.com", :password => "unsupervised", :dev_key => "AI39si4iWjIA8z-kwuLxWbEfu-4WUfvzi8LxuguBvxgSl2VaUoYDj_L_J8QRBsZivSH92msVpJPUMRuRegY1mp_mh57X32Mh0g")
  end


end
