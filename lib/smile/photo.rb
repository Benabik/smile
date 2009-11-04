# 
#  photo.rb
#  smile
#  
#  Created by Zac Kleinpeter on 2009-04-28.
#  Copyright 2009 Cajun Country. All rights reserved.
# 
#
class Smile::Photo < Smile::Base
  
  class << self
    # Convert the given xml into photo objects to play with
    def from_json( json, session_id )
      result = JSON.parse( json )
      
      result["Images"].map do |image_upper|
        image = upper_hash_to_lower_hash( image_upper )
        image.merge!( :image_id => image["id"] )
        image.merge!( :album_key => image["album"]["key"] )
        image.merge!( :album_id => image["album"]["id"] )
        image.delete( 'album' )
      
        p = Smile::Photo.new( image )
        p.session_id = session_id
        p
      end
    end
    
    # This will pull a single image from the smugmug
    #
    # *Options* (given as a Hash)
    # * :+image_id+ - Integer
    # * :+password+ - String (optional)
    # * :+site_password+ - String (optional)
    # * :+image_key+ - String
    def find( options={} )
      set_session if( session_id.nil? )
      options = Smile::ParamConverter.clean_hash_keys( options )
      
      params = default_params.merge(
          :method => 'smugmug.images.getInfo'
      )
      
      params.merge!( options ) if( options )
      json = RestClient.post Smile::Base::BASE, params
      image_upper = JSON.parse( json )
      image = upper_hash_to_lower_hash( image_upper['Image'] )
      
      image.merge!( :image_id => image["id"] )
      image.merge!( :album_key => image["album"]["key"] )
      image.merge!( :album_id => image["album"]["id"] )
      image.delete( 'album' )
      
      p = Smile::Photo.new( image )
      p.session_id = session_id
      p
    end
  end
  
  # This method will return camera and photograph details about the image
  # specified by ImageID.  The Album must be owned by the Session holder,
  # or else be Public (if password-protected, a Password must be provided),
  # to return results. Otherwise, an "invalid user" faultCode will result.
  # Additionally, the album owner must have specified that EXIF data is
  # allowed. Note that many photos have no EXIF data, so an empty or
  # partially returned result is very normal.
  #
  # *Options* (passed as Hash, optional)
  # * :+password+ - String
  # * :+site_password+ - String
  #
  # Returns an OpenStruct with the following attributes:
  #
  # id:: int
  # DateTime:: String
  # DateTimeOriginal:: String
  # DateTimeDigitized:: String
  # Make:: String
  # Model:: String
  # ExposureTime:: String
  # Aperture:: String
  # ISO:: int
  # FocalLength:: String
  # FocalLengthIn35mmFilm:: int
  # CCDWidth:: String
  # CompressedBitsPerPixel:: String
  # Flash:: int
  # Metering:: int
  # ExposureProgram:: int
  # ExposureBiasValue:: String
  # ExposureMode:: int
  # LightSource:: int
  # WhiteBalance:: int
  # DigitalZoomRatio:: String
  # Contrast:: int
  # Saturation:: int
  # Sharpness:: int
  # SubjectDistance:: String
  # SubjectDistanceRange:: int
  # SensingMethod:: int
  # ColorSpace:: String
  # Brightness:: String
  def details( options =nil )
    params = default_params.merge(
      :method => "smugmug.images.getEXIF",
      :ImageID => self.image_id,
      :ImageKey => self.key
    )
    
    params.merge!( options ) if( options )
    json = RestClient.post Smile::Base::BASE, params
    
    json = JSON.parse( json )
    raise json["message"] if json["stat"] == 'fail'
      
    image = upper_hash_to_lower_hash( json['Image'] )
    image.merge!( :image_id => image["id"] )
    
    OpenStruct.new( image )
  end
  
  # This method will return details about the image specified by ImageID.
  # The Album must be owned by the Session holder, or else be Public (if
  # password-protected, a Password must be provided), to return results..
  # Otherwise, an "invalid user" faultCode will result. Additionally, some
  # fields are only returned to the Album owner.
  # 
  # *Options* (passed as Hash, optional)
  # * :+password+ - String
  # * :+site_password+ - String
  #
  # Returns an OpenStruct with the following attributes:
  # id:: int
  # Caption:: String
  # Position:: int
  # Serial:: int
  # Size:: int
  # Width:: int
  # Height:: int
  # LastUpdated:: String
  # FileName:: String, owner only
  # MD5Sum:: String, owner only
  # Watermark:: String, owner only
  # Hidden:: Boolean, owner only
  # Format:: String, owner only
  # Keywords:: String  
  # Date:: String, owner only
  # AlbumURL:: String 
  # TinyURL:: String 
  # ThumbURL:: String 
  # SmallURL:: String 
  # MediumURL:: String 
  # LargeURL:: String (if available)
  # XLargeURL:: String (if available)
  # X2LargeURL:: String (if available)
  # X3LargeURL:: String (if available)
  # OriginalURL:: String (if available)
  # Album:: Hash
  #         id:: integer 
  #         Key:: String 
  def info( options =nil )
    params = default_params.merge(
      :method => "smugmug.images.getInfo",
      :ImageID => self.image_id,
      :ImageKey => self.key
    )
    
    params.merge!( options ) if( options )
    json = RestClient.post Smile::Base::BASE, params
    
    json = JSON.parse( json )
    raise json["message"] if json["stat"] == 'fail'
      
    image = upper_hash_to_lower_hash( json['Image'] )
    image.merge!( :image_id => image["id"] )
    
    OpenStruct.new( image )  
  end
  
  # This method will return all the URLs for the various sizes of the image
  # specified by ImageID. The Album must be owned by the Session holder, or
  # else be Public (if password-protected, a Password must be provided), to
  # return results. Otherwise, an "invalid user" faultCode will result.
  # Additionally, obvious restrictions on Originals and Larges apply if so
  # set by the owner. They will return as empty strings for those URLs if
  # they're unavailable.
  # 
  # *Options* (passed as Hash, optional)
  # * :+TemplateID+ - Integer
  #   3:: Elegant (default)
  #   4:: Traditional
  #   7:: All Thumbs
  #   8:: Slideshow
  #   9:: Journal
  # * :+password+ - String
  # * :+site_password+ - String
  # 
  # Returns an OpenStruct with the following attributes:
  # AlbumURL:: String 
  # TinyURL:: String 
  # ThumbURL:: String 
  # SmallURL:: String 
  # MediumURL:: String 
  # LargeURL:: String (if available)
  # XLargeURL:: String (if available)
  # X2LargeURL:: String (if available)
  # X3LargeURL:: String (if available)
  # OriginalURL:: String (if available)
  def urls( options =nil )
    params = default_params.merge(
      :method => "smugmug.images.getURLs",
      :ImageID => self.image_id,
      :ImageKey => self.key
    )
    
    params.merge!( options ) if( options )
    json = RestClient.post Smile::Base::BASE, params
    
    json = JSON.parse( json )
    raise json["message"] if json["stat"] == 'fail'
      
    image = upper_hash_to_lower_hash( json['Image'] )
    image.merge!( :image_id => image["id"] )
    
    OpenStruct.new( image )  
  end
  
  def album
    Smile::Album.find( :AlbumID => album_id, :AlbumKey => album_key )
  end
end
