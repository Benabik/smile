#  Created by Zac Kleinpeter on 2009-04-28.
#  Copyright 2009 Cajun Country. All rights reserved.

# Contains the information about a SmugMug album
# 
# Every Album will contain the following attributes:
#
# id:: Integer
# key:: String
# title:: String
# category:: Hash
#            id:: String
#            Name:: String
# subcategory:: Hash
#               id:: String
#               Name:: String
#
# An Album from a heavy responce will also contain:
#   
# description:: String
# keywords:: String
# position:: Integer
# imagecount:: Integer
# lastupdated:: String
#
# If logged in as the owner of a photo, it will also have:
#
# geography:: Boolean
# hightlight:: Hash
#              id:: String
# clean:: Boolean
# exif:: Boolean
# filenames:: Boolean
# template:: Hash
#            id:: String
# sortmethod:: String
# sortdirection:: Boolean
# password:: String
# passwordhint:: String
# public:: Boolean
# worldsearchable:: Boolean
# smugsearchable:: Boolean
# external:: Boolean
# hideowner:: Boolean
# x2larges:: Boolean
# x3larges:: Boolean
# originals:: Boolean
# canrank:: Boolean
# friendedit:: Boolean
# familyedit:: Boolean
# comments:: Boolean
# share:: Boolean
# printable:: Boolean
# colorcorrection:: Int
# community:: Hash
#             id:: String
#
# Power & Pro users will also get:
#
# header:: Boolean
# protected:: Boolean
# unsharpamount:: Float
# unsharpradius:: Float
# unsharpthreshold:: Float
# unsharpsigma:: Float
#
# Pro users will also get:
#
# watermarking:: Boolean
# watermark:: Hash
#             id:: String
# larges:: Boolean
# xlarges:: Boolean
# defaultcolor:: Boolean (deprecated)
# proofdays:: Integer
# backprinting:: String
#  
class Smile::Album < Smile::Base

  class << self
    def from_json( json, session_id )
      json["Albums"].map do |album_upcase|
        album = upper_hash_to_lower_hash( album_upcase )
        
        album.merge!( :album_id => album["id"] )
        
        a = Smile::Album.new( album )
        a.session_id = session_id
        a
      end
    end
    
    # This will pull a single album from the smugmug
    #
    # * SessionID - string. (by default if logged in)
    # * AlbumID - string.
    # * Password - string (optional).
    # * SitePassword - string (optional).
    # * AlbumKey - string.
    # 
    def find( options )
      album_upper = request 'albums.getInfo', options
    
      album = upper_hash_to_lower_hash( album_upper['Album'] )
      album.merge!( :album_id => album["id"] )
      
      a = Smile::Album.new( album )
      a.session_id = session_id
      a
    end
    
    # Creates a new Album with the following information
    #
    # * title - string, what you want to call it
    # * options - hash (optional, all keys optional)
    #   
    #   *Essentials*
    #   * :+category_id+ - Integer, ID for album category
    #   * :+sub_category_id+ - Integer, ID for album subcategory
    #   * :+description+ - String, album description
    #   * :+keywords+ - String, XXX: space seperated or comma?
    #   * :+album_template_id+ - Integer, default: 0
    #   * :+geography+ - Boolean, default: false
    #   * :+highlight_id+ - Integer
    #   * :+position+ - Integer
    #
    #   *Look & Feel*
    #   * :+header+ - Boolean, default: false (Power & Pro only)
    #   * :+clean+ - Boolean, default: false
    #   * :+exif+ - Boolean, default: true
    #   * :+filenames+ - Boolean, show file names (default: false)
    #   * :+square_thumbs+ - Boolean, default: true
    #   * :+template_id+ - Integer
    #     0:: Viewer Choice (default)
    #     3:: SmugMug
    #     4:: Traditional
    #     7:: All Thumbs
    #     8:: Slideshow
    #     9:: Journal
    #     10:: SmugMug Small
    #     11:: Filmstrip
    #   * :+sort_method+ - String
    #     * Position (default)
    #     * Caption
    #     * FileName
    #     * Date
    #     * DateTime
    #     * DateTimeOriginal
    #   * :+sort_direction+ - Boolean (true is ascending)
    #
    #   *Security & Privacy*
    #   * :+password+ - String
    #   * :+password_hint+ - String
    #   * :+public+ - Boolean, default: true
    #   * :+world_searchable+ - Boolean, default: true
    #   * :+smug_searchable+ - Boolean, default: true
    #   * :+external+ - Boolean, default: true
    #   * :+protected+ - Boolean, default: false (Power & Pro only)
    #   * :+watermarking+ - Boolean, default: false (Pro only)
    #   * :+watermark_id+ - Integer, default: false
    #   * :+hide_owner+ - Boolean, default: false
    #   * :+larges+ - Boolean, default: true
    #   * :+x_larges+ - Boolean, default: true
    #   * :+x2_larges+ - Boolean, default: true
    #   * :+x3_larges+ - Boolean, default: true
    #   * :+originals+ - Boolean, default: true
    #
    #   *Social*
    #   * :+can_rank+ - Boolean, default: true
    #   * :+friend_edit+ - Boolean, default: false
    #   * :+family_edit+ - Boolean, default: false
    #   * :+comments+ - Boolean, default: true
    #   * :+share+ - Boolean, default: true
    #
    #   *Printing & Sales*
    #   * :+printable+ - Boolean, default: true
    #   * :+color_correction+ - Integer
    #     0:: No
    #     1:: Yes
    #     2:: Inherit (default)
    #   * :+default_color+ - Boolean, (Pro only, *deprecated*)
    #     true:: Auto Color
    #     false:: True Color (default)
    #   * :+proof_days+ - Integer, default: 0 (Pro only)
    #   * :+back_printing+ - String (Pro only)
    #
    #   *Photo Sharpening* (Power & Pro only)
    #   * :+unsharp_amount+ - Float, default: 0.200
    #   * :+unsharp_radius+ - Float, default: 1.000
    #   * :+unsharp_threshold+ - Float, default: 0.050
    #   * :+unsharp_sigma+ - Float, default: 1.000
    #
    #   *Community*
    #   * :+community_id+ - Integer, default: 0
    def create( title, options )
      options[:title] = title
      json = request 'albums.create', options
      find( :album_id => json["Album"]["id"], :album_key => json["Album"]["Key"] )
    end
  end

  # Update the album from the following params
  #
  # See #create for options
  def update( options )
    request 'albums.changeSettings', options, :AlbumID => album_id
    true
  end
  
  # This will pull all the photos for a given album
  # * SessionID - string. (by default if logged in)
  # * AlbumID - integer.
  # * Heavy - boolean (optional).
  # * Password - string (optional).
  # * SitePassword - string (optional).
  # * AlbumKey - string.
  def photos( options=nil )
    params = { :heavy => 1 }
    params.merge! options if options
    begin
      json = request 'images.get', params, :AlbumID => album_id, :AlbumKey => key
      Smile::Photo.from_json( json, session_id )
    rescue Smile::Failure => f
      return [] if f.code == 15 # No images
      raise
    end
  end
  
  # Pull stats for an Album for a given Month and Year
  #
  # *Options* (passed as a Hash)
  # * :+month+ - Integer, default: current month
  # * :+year+ - Integer, default: current year
  # * :+heavy+ - Boolean, also give stats per image, default: false
  def stats( options =nil )
    today = Date.today
    params = {
      :month => today.month,
      :year => today.year,
    }
    params.merge! options if options
    json = request 'albums.getStats', params, :AlbumID => album_id

    stat = upper_hash_to_lower_hash( json['Album'] )
    OpenStruct.new( stat )
  end
  
  # Add an image or vid to the existing album
  # 
  # [image]
  #   path to image
  # [options]
  #   Hash, optional
  #   * :+caption+, Use carriage return between lines
  #   * :+keywords+, String
  #   * :+latitude+, Float - Latitude in D.d format (i.e. 3.430096)
  #   * :+longitude+, Float - Longitude in D.d format (i.d. -122.152269)
  #   * :+altitude+, Fload - Altitude in meters
  def add( image, options={} )
    if( File.exists?( image ) )
      options = Smile::ParamConverter.clean_hash_keys( options ) if options
      json = RestClient.put UPLOAD + "/#{image}", File.read( image ),
        :content_length => File.size( image ),
        :content_md5 => Digest::MD5.hexdigest( File.read( image ) ),
        :x_smug_sessionid => session_id,
        :x_smug_version => VERSION,
        :x_smug_responseType => "JSON",
        :x_smug_albumid => album_id,
        :x_smug_filename => File.basename( image ),
        :x_smug_caption => options[:caption],
        :x_smug_keywords => options[:keywords],
        :x_smug_latitude => options[:latitude],
        :x_smug_longitude => options[:longitude],
        :x_smug_altitude => options[:altitude]
      
      image = JSON.parse( json )
      if( image && image["Image"] && image["Image"]["id"] )
        Smile::Photo.find( :image_id => image["Image"]["id"] )
      else
        raise Exception.new( "Failed to upload #{image}" )
      end
    else
      raise Exception.new( "Cannot find file #{image}." )
    end
  end
  
  # Deletes the album
  def delete!
    json = request 'albums.delete', nil, :AlbumID => album_id
    
    album_id = nil
    album_key = nil
    nil
  end
  
  
  # This method will re-sort all the photos inside of the album specified by 
  # AlbumID. Note that this is a one-time event, 
  # and doesn't apply directly to images added in the future by other means.
  def resort!
    json = request 'albums.reSort', nil, :AlbumID => album_id
    
    album_id = nil
    album_key = nil
    nil
  end
  
  def category
    ['category']
  end
end
