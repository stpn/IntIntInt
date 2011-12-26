class EvaluationController < ApplicationController

  def edit
    #this is looping through phrases while it should be looping through connotations or shit like that...
    @relevant_phrases = current_user.good_phrases_for_user
    @relevant_phrases = Kaminari.paginate_array(@relevant_phrases).page(params[:page]).per(25)
    respond_to do |format|
 
#       !
      format.html
    end
  end


  def update
    rating = params[:rating]
    respond_to do |format|
    cc =  Phrase.find(params[:ph_id]).connotations.create!(:user => current_user, :rating => rating)
    cc.save!
    end
  end


end
