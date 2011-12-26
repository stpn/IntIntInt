class PhrasesController < ApplicationController
  before_filter :require_user
  # GET /phrases
  # GET /phrases.json
  def index
    @phrases = Phrase.order(:id).page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @phrases }
    end
  end

  # GET /phrases/1
  # GET /phrases/1.json
  def show
    @phrase = Phrase.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @phrase }
    end
  end

  # GET /phrases/new
  # GET /phrases/new.json
  def new
    @phrase = Phrase.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @phrase }
    end
  end

  # GET /phrases/1/edit
  def edit
        @relevant_phrases = current_user.good_phrases_for_user
        @relevant_phrases = Kaminari.paginate_array(@relevant_phrases).page(params[:page]).per(25)
  end

  # POST /phrases
  # POST /phrases.json
  def create
    @phrase = Phrase.new(params[:phrase])

    respond_to do |format|
      if @phrase.save
        format.html { redirect_to @phrase, notice: 'Phrase was successfully created.' }
        format.json { render json: @phrase, status: :created, location: @phrase }
      else
        format.html { render action: "new" }
        format.json { render json: @phrase.errors, status: :unprocessable_entity }
      end
    end
  end
  
  

  # PUT /phrases/1
  # PUT /phrases/1.json
  def update
    @phrase = Phrase.find(params[:id])
    @connotation = @phrase.connotations << Connotation.create(params[:new_connotation])
    respond_to do |format|

      if @phrase.update_attributes(params[:phrase])
        format.html { redirect_to(:back) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @phrase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phrases/1
  # DELETE /phrases/1.json
  def destroy
    @phrase = Phrase.find(params[:id])
    @phrase.destroy

    respond_to do |format|
      format.html { redirect_to phrases_url }
      format.json { head :ok }
    end
  end
end
