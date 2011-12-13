class EvaluationController < ApplicationController

  def edit

    @relevant_phrases = Phrase.all_relevant_phrases
    rating = params[:rating]
    phraseid = params[:phraseid]

        
    respond_to do |format|
      @phrase = Phrase.find(params[:id => phraseid])
      @phrase.add_connotation(rating)      
      format.html
      format.json {render json: @evaluation}
    end
  end


end