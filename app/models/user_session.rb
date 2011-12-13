class UserSession < Authlogic::Session::Base
  
 ignore_blank_passwords = false
   
  def to_key
      new_record? ? nil : [ self.send(self.class.primary_key) ]
   end

   def persisted?
     false
   end
   
end
