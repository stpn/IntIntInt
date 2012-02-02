module NewThings
  module ClassMethods

  def stringed_hash
      return Hash.new{|h,k| h[k] = "" }
    
  end
  
  
  #######FIND CLOSEST NUMBER, APP-AGNOSTIC

  def find_closest_number(array_of_numbers, target_number)
    closer_num = 0.0001
    if !array_of_numbers.blank?
      if array_of_numbers.length == 1
        closer_num = array_of_numbers[0]
      else
        ary = array_of_numbers.partition do |elmt|
          elmt < target_number
        end
        lowest = ary[0].max
        highest = ary[1].min
        if lowest.nil?
          closer_num = highest
        elsif highest.nil?
          closer_num = lowest
        elsif (highest - target_number > target_number - lowest)
          closer_num = highest
        else
          closer_num = lowest
        end
      end
    end
    return closer_num
  end
  
end 


 def self.included(receiver)
   receiver.extend ClassMethods
 end

end