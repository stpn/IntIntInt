class User < ActiveRecord::Base


  attr_accessor :ignore_blank_passwords
  
  acts_as_authentic do |c|
    c.validate_password_field = false
    c.validate_password_field = false
    
    c.validate_email_field = false
    end

      # object level attribute overrides the config level
      # attribute
      def ignore_blank_passwords?
        ignore_blank_passwords.nil? ? super : (ignore_blank_passwords == true)
      end

  
end
