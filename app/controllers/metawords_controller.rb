class MetawordsController < ApplicationController
  # GET /metawords
  # GET /metawords.json
  def index
    @metawords = Metaword.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @metawords }
    end
  end

  # GET /metawords/1
  # GET /metawords/1.json
  def show
    @metaword = Metaword.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @metaword }
    end
  end

  # GET /metawords/new
  # GET /metawords/new.json
  def new
    @metaword = Metaword.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @metaword }
    end
  end

  # GET /metawords/1/edit
  def edit
    @metaword = Metaword.find(params[:id])
  end

  # POST /metawords
  # POST /metawords.json
  def create
    @metaword = Metaword.new(params[:metaword])

    respond_to do |format|
      if @metaword.save
        format.html { redirect_to @metaword, notice: 'Metaword was successfully created.' }
        format.json { render json: @metaword, status: :created, location: @metaword }
      else
        format.html { render action: "new" }
        format.json { render json: @metaword.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /metawords/1
  # PUT /metawords/1.json
  def update
    @metaword = Metaword.find(params[:id])

    respond_to do |format|
      if @metaword.update_attributes(params[:metaword])
        format.html { redirect_to @metaword, notice: 'Metaword was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @metaword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metawords/1
  # DELETE /metawords/1.json
  def destroy
    @metaword = Metaword.find(params[:id])
    @metaword.destroy

    respond_to do |format|
      format.html { redirect_to metawords_url }
      format.json { head :ok }
    end
  end
end
