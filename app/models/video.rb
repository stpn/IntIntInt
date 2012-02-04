class Video < ActiveRecord::Base
  attr_accessor :video_array

  has_many :phrases

  has_many :memberships
  has_many :metawords, :through => :memberships



  def self.pull_videos_from_youtube(query, video_array)
    video_array = []
    video_string = String.new
    keywords_array = Array.new
    views_array = Array.new
    id_array = Array.new
    query.videos.each do |wow|
      video_string = wow.video_id
      content_string = video_string[/video:(.*)/]
      real_video_id = $1
      keywords_string = wow.keywords
      video_hash  = {real_video_id => keywords_string}
      video_array.push video_hash
    end
    return video_array
  end


  def self.check_db_for_yt(video_array)
    video_array.each do |hash|
      hash.each do |k, v|
        video_find = Video.find_by_content(k)
        video_find2 = Discard.find_by_youtubeid(k)
        if !video_find.blank?
          hash.delete(k)
        end
      end
    end
    video_array.delete_if{|h| h.empty?}

    return video_array
  end



  def self.load_comments(youtube_id)
    @comments_content = String.new
    @comments_array = Array.new
    comments_query = Video.yt_session.comments(youtube_id)

    comments_query.each do |comment|
      @comments_content = "PARSEFROMHERE " + comment.content + " ENDPARSEFROMHERE"
      matches = @comments_content.match(/\d+:\d+/)
      if !matches.nil?
        @comments_array.push @comments_content
      end
    end
    return @comments_array
  end

  ###DOES IT EVEN WORKK???
  def self.make_metawords(video)
    kw = video.keywords.split("\n- ")
    kw.delete("---")
    kw.each do |b|
      b.each do |k|
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
  #################



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




  def self.for_each(conditions = nil, step = 25, &block)
    c = count :conditions => conditions
    (c / step).times do |i|
      find(:all, :conditions => conditions,
      :limit => step,  :offset => step * i).each do |model|
        yield model
      end
    end
  end


  def self.remove_videos_without_downloads
    #This deletes objects that don't have corresponding files
    objects_list = String.new
    f = File.open('downloads.txt', 'r')
    video_list = f.read
    time = Time.now.getutc
    time = time.to_s
    File.open(time+'existing_dls.txt', 'a') {|f| f.write(video_list) }

    #        video_list = %{}
    Video.all.each do |v|
      objects_list << v.content
    end
    parsed = objects_list.split.reject { |w| video_list.include?(w) }.join(' ')
    bad_guys = objects_list - parsed
    bad_guys.each do |p|
      wrong = Video.find_by_content(p)
      Video.destroy(wrong)
    end
  end

  def self.create_list_of_videos_with_downloads
    vids = Video.find_all_by_download(true)

    time = Time.now.getutc
    time = time.to_s
    content_string = Array.new
    vids.each do |v|
      content_string << v.content
    end

    File.open(time+'vid_w_dls.txt', 'a') {|f| f.write(content_string) }
  end



  def self.remove_all_duplicates
    (Video.all - Video.all.uniq_by{|r| [r.content]}).each{ |d| d.destroy }
  end


  def self.get_file_as_string(filename)
    data = ''
    f = File.open(filename, "r")
    f.each_line do |line|
      data += line
    end
    return data
  end


  def self.all_relevant_videos
    videos_with_non_nil_comments = Video.find(:all, :conditions => "comments IS NOT NULL")

    #          video = Video.find_all_by_download(true)
    return videos_with_non_nil_comments
  end

  def self.yt_session
    @yt_session ||= YouTubeIt::Client.new( :username => "auvproj@gmail.com", :password => "unsupervised", :dev_key => "AI39si4iWjIA8z-kwuLxWbEfu-4WUfvzi8LxuguBvxgSl2VaUoYDj_L_J8QRBsZivSH92msVpJPUMRuRegY1mp_mh57X32Mh0g")
  end




  def self.getcsv
    videos = Video.find(:all)
    csv_string = CSV.generate do |csv|
      csv << [
        "name",
        "content",
        "comments",
        "keywords"
      ]
      videos.each do |video|
        csv << [video.name,
                video.content,
                video.comments,
                video.keywords]
      end
    end
    File.open('video_csv.csv', 'a') {|f| f.write(csv_string) }

  end

  def self.load_from_csv
    CSV.parse(File.open("video_csv.csv", 'rb')) do |row|
      Video.create(:content => row[1], :comments => row[2], :keywords => row[3])
    end
  end



end
