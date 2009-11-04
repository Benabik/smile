require 'activesupport'
require 'restclient'
require 'ostruct'
require 'smile/base'
require 'smile/smug'
require 'smile/album'
require 'smile/photo'
require 'smile/param_converter'
require 'cgi'
require 'rss'
require 'json'

module Smile
  module_function
  
  # Create a Smile::Smug that is logged into an anonymous account
  #
  # See Smile::Smug#auth_anonymously
  def auth_anonymously
    smug = Smile::Smug.new
    smug.auth_anonymously
    smug
  end
  
  # Create a Smile::Smug that is logged into an account
  #
  # See Smile::Smug#auth
  def auth( email, password )
    smug = Smile::Smug.new
    smug.auth( email, password )
    smug
  end
  
  
  def base_feed( options={} )
    options.merge!( :format => 'rss' )
    url = "http://api.smugmug.com/hack/feed.mg?"
    url_params =[]
    options.each_pair do |k,value|
      key, value = Smile::ParamConverter.convert( k, value )
      
      url_params << "#{key.to_s}=#{ CGI.escape( value ) }"
    end
    
    RestClient.get( url + url_params.join( "&" ) )
  end
  private( :base_feed )
  
  # Search SmugMug for pictures using the feeds.
  #
  # This search is slower than the others, because it pulls details from
  # every photo to return an Array of Smile::Photo objects
  # 
  # [data]
  #   Search term
  # [options]
  #   (Optional) Hash with more options:
  #   [:+keyword+] Override the keyword search
  #   [:+popular+] Use term all or today
  #   [:+popular_category+] Use term category (e.g. cars)
  #   [:+geo_all+] Geo Stuff
  #   [:+geo_community+] More Geo Stuff
  #   [:+geo_search+] Geo Search
  #   [:+open_search_keyword+] Key word
  #   [:+user_keyword+] Use term nickname
  #   [:+gallery+] Use term albumID_albumKey
  #   [:+nickname+] Use term nickname
  #   [:+nickname_recent+] Use term nickname
  #   [:+nickname_popular+] Use term nickname
  #   [:+user_comments+] Use term nickname
  #   [:+geo_user+] Use term nickname
  #   [:+geo_album+] Use term nickname
  def search( data, options={} )
    rss = search_rss( data, options )
    
    rss.items.map do |item| 
      image_id, image_key = item.link.split('/').last.split('#').last.split('_')
      Smile::Photo.find( :image_id => image_id, :image_key => image_key )
    end
  end
  
  # Search SmugMug for pictures using the feeds.
  #
  # Takes the same arguments as #search.
  # Returns the result of RSS::Parser.parse
  #
  # Takes the same arguments as #search
  def search_rss( data, options={} )
    raw = search_raw( data, options )
    RSS::Parser.parse( raw, false )
  end
  
  # Raw feed from the SmugMug data feeds
  # 
  # Takes the same arguments as #search.
  # Returns a RestClient::Response (which can just be used as a string).
  def search_raw( data, options={} )
    options.merge!( :type => 'keyword', :data => data )
    base_feed( options )
  end
end

