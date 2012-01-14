module ParsingHelpers
  module ClassMethods
    
    def stop_words
       @stop_words = %w{able about across after all almost also am
                        among an and any are as at be because been but by can cannot
                        could dear did do does either else ever every for from get got
                          had has have he her hers him his how however i if in into is
                          it its just least let like likely may me might most must my
                          neither no nor not of off often on only or other our own rather re
                          said say says she should since so some than that the their them
                          then there these they this tis to too twas us wants was we were
                            what when where which while who whom why will with would yet you your a b c d e f g h i j k l m n o p q r s t u v w x y z}
       return @stop_words                      
    end

   def remove_stop_words(array)
     array = array.reject { |w| stop_words.include?(w.gsub(/[\.,;:\-{}\[\]()]/, '')) }
     return array
   end
end 


 def self.included(receiver)
   receiver.extend ClassMethods
 end

end
