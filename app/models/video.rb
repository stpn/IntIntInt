class Video < ActiveRecord::Base
  attr_accessor :video_array

  has_many :phrases

  has_many :memberships
  has_many :metawords, :through => :memberships

  @page = 1
  @number = 1
  @indexing = 1

  #This is the code that was loading videos

  def self.load_video(number, page, indexing)
    @dl_string = String.new
    @page = number
    @number = page
    @indexing = indexing
    puts "AUV Project, page equals "+ page.to_s
    puts "AUV Project, views equals "+ number.to_s
    if @video_array.nil?
      @video_array = Array.new
    end
    query ||= Video.yt_session.videos_by(:view_count => number, :max_results => 15, :page => page, :index => indexing, :per_page => 15)
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
        @video_find2 = Discard.find_by_youtubeid(k)
        if !@video_find.blank?
          hash.delete(k)
        end
      end
    end
    @video_array.delete_if{|h| h.empty?}
    if !@video_array.empty?
      @video_array.each do |hash|
        hash.each do |k,v|
          @video = Video.create(:content => k, :keywords => v )
          @video.comments = Video.load_comments(k)
          @video.save!
          if @video.comments.class != "--- []\n"
            Phrase.load_all_comments(@video)
            if !@video.phrases.blank?
              @dl_string = "http://www.youtube.com/watch?v="+k
              %x[cd /Users/itp/Documents/IntIntInt_front/public/videos && /Users/itp/.rvm/gems/ruby-1.9.3-p0/gems/viddl-rb-0.5.5/bin/viddl-rb #{@dl_string}]
                 @video.save!
                 else
                   dc = Discard.create
                   dc.youtubeid = @video.content
                   dc.save
                   Video.destroy(@video)
                 end
                 end
                 end
                 end
                 end
                 if page < 19
                   sleep(30)
                   Video.load_video(number, page+1, indexing+15)
                 else
                   sleep(180)
                   Video.load_video(number+10000, 1, 0)
                 end
                 end



                 def self.load_comments(youtube_id)
                   @comments_content = String.new
                   @comments_array = Array.new
                   comments_query ||= Video.yt_session.comments(youtube_id)
                 rescue
                   sleep(120)
                   if (@page < 19)
                     Video.load_video(@number, @page+1, @indexing+15)
                   else
                     Video.load_video(@number+5000, 1, 0)
                   end
                 else
                   comments_query.each do |comment|
                     @comments_content = "PARSEFROMHERE " + comment.content + " ENDPARSEFROMHERE"
                     matches = @comments_content.match(/\d+:\d+/)
                     if !matches.nil?
                       @comments_array.push @comments_content
                     end
                   end
                   return @comments_array
                 end


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



                 def self.load_comments(youtube_id)
                   @comments_content = String.new
                   @comments_array = Array.new
                   comments_query ||= Video.yt_session.comments(youtube_id)
                 rescue
                   sleep(120)
                   if (@page < 19)
                     Video.load_video(@number, @page+1, @indexing+15)
                   else
                     Video.load_video(@number+5000, 1, 0)
                   end
                 else
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
                   @dl_string = String.new
                   @y_ids = Video.collect_ids_for_download
                   @y_ids.each do |v|
                     @dl_string = "http://www.youtube.com/watch?v="+v
                     %x[cd /Users/stepanboltalin/Documents/Rails/Intel/IntIntInt_front/public/videos && /Users/stepanboltalin/.rvm/gems/ruby-1.9.3-p0/gems/viddl-rb-0.5.5/bin/viddl-rb #{@dl_string}]

                        #      sleep(20)
                        end

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
                          video = Video.find_all_by_download(true)
                          return video
                        end

                        end
