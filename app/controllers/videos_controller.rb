class VideosController < ApplicationController
  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all
    respond_to do |format|
      format.html
      format.json { render json: @videos }
    end
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
    @video = Video.find(params[:id])


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @video }
    end
  end

  # GET /videos/new
  # GET /videos/new.json
  def new
    @video = Video.new

    number = params[:number]




    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @video }
    end
  end





  # GET /videos/1/edit
  def edit
    @video = Video.find(params[:id])

  end

  # POST /videos
  # POST /videos.json
  def create
    number = params[:number]
    @name = number
    @video_content = Video.load_video(number)
    @video_content.each do |youtube_id|
      @video = Video.new
      @video.content = youtube_id
      @video.name = @name
      @video.comments = Video.load_comments(youtube_id)
      @video.save
    end
    


    respond_to do |format|
      if @video.save
        format.html { redirect_to @video, notice: 'Video was successfully created.' }
        format.json { render json: @video, status: :created, location: @video }
      else
        format.html { render action: "new" }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /videos/1
  # PUT /videos/1.json
  def update
    @video = Video.find(params[:id])


    respond_to do |format|
      if @video.update_attributes(params[:video])
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video = Video.find(params[:id])
    @video.destroy

    respond_to do |format|
      format.html { redirect_to videos_url }
      format.json { head :ok }
    end
  end
end
