class Connotation < ActiveRecord::Base
belongs_to :phrase
has_many :evaluations


end
