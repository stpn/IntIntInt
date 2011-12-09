class EvaluationController < ApplicationController

  def edit

    @phrase = Phrase.all
    @relevant_phrases = Phrase.all_relevant_phrases
    respond_to do |format|
      format.html
      format.json {render json: @words}
    end
  end


end