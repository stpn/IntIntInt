class UserSession < Authlogic::Session::Base
  
  find_by_login_method :find_by_username_or_mobile
  
  
  
  
  def authenticating_with_password?
      false
    end
   
  def to_key
      new_record? ? nil : [ self.send(self.class.primary_key) ]
   end

   def persisted?
     false
   end
   
end
