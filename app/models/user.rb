class User < ActiveRecord::Base

  has_many :connotations, :dependent => :destroy
  attr_accessor :ignore_blank_passwords

  
  acts_as_authentic do |c|
    c.validate_password_field = false
    c.check_passwords_against_database = false
    c.crypted_password_field = false
    c.validate_email_field = false
  end
  
  def self.find_by_username_or_mobile(login)
     find_by_login(login) || find_by_mobile(login)
   end

  # object level attribute overrides the config level
  # attribute
  def ignore_blank_passwords?
    ignore_blank_passwords.nil? ? super : (ignore_blank_passwords == true)
  end


  def good_phrases_for_user
    phraseids = Array.new
    self.connotations.each do |o|
          phraseids.push o.phrase_id
    end
    phrases = Array.new
    Phrase.find_each do |ph|
      unless phraseids.include?(ph.id)
        phrases << ph
      end
    end
    return phrases
  end


end
