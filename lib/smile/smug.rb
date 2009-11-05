# 
#  smug.rb
#  smile
#  
#  Created by Zac Kleinpeter on 2009-04-28.
#  Copyright 2009 Cajun Country. All rights reserved.
# 
module Smile
  class Smug < Smile::Base
 
    # Login to SmugMug using a specific user account.
    #
    # [email] String: The username ( Nickname ) for the SmugMug account
    # [password] String: The password for the SmugMug account
    #
    # Returns the server responce
    def auth( email, pass )
      result = request 'login.withPassword', nil,
        :EmailAddress => email, :Password => pass
      self.session_id = result["Login"]["Session"]["id"]
      result
    rescue NoMethodError => e
      nil
    end

    # Login to SmugMug using an anonymously account
    #
    # This will allow you to execute many functions, but no user specific functions
    #
    # Returns the server responce
    def auth_anonymously
      result = request 'login.anonymously'
      self.session_id = result["Login"]["Session"]["id"]
      result
    rescue NoMethodError => e
      nil
    end

    # Close the session
    def logout
      request 'logout'
    end

    

    # Retrieves a list of albums for a given user. If you are logged in it
    # will return your albums.
    # 
    # *Options* (passed as Hash, optional)
    # * :+nick_name+ - String, default: logged in user
    # * :+heavy+ - Boolean, get full information about an album, default: true
    # * :+site_password+ - String, if you have not logged in then you can
    #   provide the password here to access private information
    #
    # Returns an Array of Smile::Album
    # 
    # See Smile::Album#new For more information about heavy (true and false) responces
    def albums( options=nil )
      params = { :heavy => 1 }
      params.merge! options if options
      json = request 'albums.get', params
      
      Smile::Album.from_json( json, session_id )
    rescue
      nil
    end
  end
end
