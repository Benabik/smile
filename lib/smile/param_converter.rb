module Smile::ParamConverter
  module_function
  
  # Pre-load the cache with exceptions
  @cache = {
    :exif => :EXIF,
    :geo_album => :geoAlbum,
    :geo_all => :geoAll,
    :geo_community => :geoCommunity ,
    :geo_keyword => :geoKeyword,
    :geo_search => :geoSearch,
    :geo_user => :geoUser,
    :nickname => :NickName,
    :nickname_popular => :nicknamePopular,
    :nickname_recent => :nicknameRecent,
    :open_search_keyword => :openSearchKeyword,
    :popular_category => :popularCategory,
    :square_thumbs => :Square_Thumbs,
    :user_comments => :userComments,
    :user_keyword => :userkeyword,
    :xlarges => :XLarges,
    :x2larges => :X2Larges,
    :x3larges => :X3Larges,
  }

  # Takes a key and returns a cleaned version.
  #
  # Param is camelized and any final _id is turned to ID.  The final key is
  # always a Symbol.  There are a number of exceptions to this rule stored
  # in the initial @cache.
  #
  # *Examples*
  # * convert( :album_id ) == :AlbumID
  # * convert( 'nick_name' ) == :NickName
  def convert( param )
    key = @cache[param]
    unless key
      key = param.to_s.camelize
      key.sub! /Id$/, 'ID'
      @cache[param] = key = key.to_sym
    end
    key
  end
  
  # Calls convert on every key in a hash
  def clean_hash_keys( hash_to_clean )
    cleaned_hash ={}
    hash_to_clean.each_pair do |key,value|
      cleaned_hash[convert( key )] = value
    end
    cleaned_hash
  end
  
end
