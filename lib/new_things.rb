module NewThings
  module ClassMethods

  def stringed_hash
    return Hash.new{|h,k| h[k] = "" }
  end
end 


 def self.included(receiver)
   receiver.extend ClassMethods
 end

end