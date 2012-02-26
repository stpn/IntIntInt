class Video < ActiveRecord::Base
  attr_accessor :video_array

  has_many :phrases

  has_many :memberships
  has_many :metawords, :through => :memberships



  def self.pull_videos_from_youtube(query)
    video_array = []
    query.videos.each do |wow|
      video_array = video_array + Video.process_single_yt_from_query(wow)
    end
    return video_array
  end

  def self.process_single_yt_from_query(wow)
    video_array = []
    video_string = wow.video_id
    duration = wow.duration
    content_string = video_string[/video:(.*)/]
    print "BOOOO"
    real_video_id = $1 +" DURATION #{duration}"
    keywords_string = wow.keywords
    video_hash  = {real_video_id => keywords_string}
    print video_hash
    video_array.push video_hash
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

  def self.pull_remaining_from_youtube
    i = 0
    videos = []
    f = File.open('remain.txt', 'rb')
    video_list = f.read
    video_list = video_list.split(' ')
    video_list.each do |ytid|
      v = Video.find_by_content(ytid)
      if !v.nil?
        v.destroy
      end
    end
    video_list.each do |ytid|
      if Video.find_by_content(ytid).nil?
        i = i+1
        query = Video.yt_session.video_by(ytid)
        #RESCUE THIS:
        video_array = Video.process_single_yt_from_query(query)

        if !video_array.empty?
          video_array.each do |hash|
            hash.each do |k,v|
              comments = Video.load_comments(k)
              if comments != "--- []\n"
                vid = Video.create
                vid.content  = k
                vid.keywords = v
                vid.comments = comments
                vid.download = true
                vid.save!
                #            (:content => k, :keywords => v, :comments => comments )
                videos << vid.content
              end
            end
          end
        end
        if i == 15
          sleep(5)
          i = 0
        end
      end
    end
    File.open('remained_w_cmnts.txt', 'a') {|f| f.write(videos.join(' ')) }
    return videos
  end


  def self.load_comments(youtube_id, duration)
    @comments_content = String.new
    @comments_array = Array.new
    comments_query = Video.yt_session.comments(youtube_id)
    comments_query.each do |comment|
      @comments_content = "PARSEFROMHERE " + comment.content + " ENDPARSEFROMHERE"
      matches = @comments_content.match(/\d{1,2}:\d\d/)
      if !matches.nil?
        timecode = @comments_content.scan(/(\d{1,2}:\d\d)/).join(',')
        timecode = timecode.split(',')
        puts "#{timecode} << TIMECODE for #{@comments_content}"
        time = timecode[0].split(':')
        puts "#{time} for #{youtube_id}" 
        seconds = time[1]
        puts seconds
        minutes = time[0]
        mtch2 = minutes.match(/0\d/)
        if !mtch2.nil?
          minutes = Integer(minutes[1])
        else
          minutes = Integer(minutes)
        end
        mtch = seconds.match(/0\d/)
        if !mtch.nil?
          seconds = Integer(seconds[1])
        else
          seconds = Integer(seconds)
        end
        time2 = minutes*60+seconds
        if (Integer(duration) - Integer(time2)) > 8
          @comments_array.push @comments_content
        end
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
    objects_list = ""
    f = File.open('vids_from_loc.txt', 'rb')
    video_list = f.read
    video_list = video_list.split(' ')
    #    time = Time.now.getutc
    #    time = time.to_s
    #    File.open(time+'existing_dls.txt', 'a') {|f| f.write(video_list) }
    #        video_list = %{}
    Video.all.each do |v|
      v.download = false
      v.save
    end
    video_list.each do |v|
      print v
      video = Video.find_by_content(v)
      if !video.nil?
        video.download = true
        video.save
      end
      if video.nil?
        objects_list << "#{v} "
      end
      File.open('vids_empty_db.txt', 'a') {|f| f.write(objects_list) }
    end

    #    parsed = objects_list.split.reject { |w| video_list.include?(w) }.join(' ')
    #    bad_guys = objects_list - parsed
    #    bad_guys.each do |p|
    #      wrong = Video.find_by_content(p)
    #      Video.destroy(wrong)
    #    end
    #    Video.all.each do |v|
    #      v.download = false
    #      v.save
    #    end
    #    parsed.split(' ').each do |p|
    #      good = Video.find_by_content(p)
    #      good.download = true
    #      good.save
    #    end

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


  def self.videos_phrases_timecodes_to_file
    time = Time.now.getutc
    time = time.to_s
    timecode = ""
    vid_str = ""
    vid_comm_str = ""
    dl = false
    dl2 = false
    Video.find_all_by_download(true).each do |v|

      ##
      if !v.phrases.nil?
        v.phrases.each do |p|
          timecode = p.timecode
          mtch2 = timecode.match(/(^\d\d:\d\d)/)
          mtch = timecode.match(/(^\d:\d\d)/)
          if !mtch.nil?
            dl = true
          elsif !mtch2.nil?
            dl2 = true
          else
            dl = false
            dl2 = false
          end
          if dl == true
            tmc2 = "00:0#{timecode}"
            tmc = tmc2[/(\d\d:\d\d:\d\d)/]
            tmc = $1
            vid_comm_str << v.content + '||||>>||<<||||' + tmc + '||||>>||<<||||' + "#{p.id}" + '||||>>||<<||||' + p.content + ' ||<><><>|| '
            vid_str << v.content + '||||>>||<<||||' + tmc + ' ||<><><>|| '
            dl = false
          end
          if dl2 == true
            tmc2 = "00:#{timecode}"
            tmc = tmc2[/(\d\d:\d\d:\d\d)/]
            tmc = $1
            vid_comm_str << v.content + '||||>>||<<||||' + tmc + '||||>>||<<||||' + "#{p.id}" + '||||>>||<<||||' + p.content + ' ||<><><>|| '
            vid_str << v.content + '||||>>||<<||||' + tmc + ' ||<><><>|| '
            dl2 = false
          end
        end
      end
    end
    i = 0
    v = 0
    vid_str.split(' ||<><><>|| ').each_slice(2000) do |ary|
      ary.each do |str|
        File.open(i.to_s+'_just_video.txt', 'a') {|f| f.puts(str) }
      end
      i = i+1
      print "#{i} "
    end
    vid_comm_str.split(' ||<><><>|| ').each_slice(2000) do |ary|
      ary.each do |str|
        File.open(v.to_s+'_video_and_comments.txt', 'a') {|f| f.puts(str) }
      end
      print "#{v} "
      v = v+1
    end

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
