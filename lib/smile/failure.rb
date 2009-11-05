# Created by Brian Gernhardt on 2009-11-05

# This class holds the error code and message from a failed SmugMug request.
class Smile::Failure < RuntimeError
  attr_accessor :code, :message
  def initialize( json )
    @message = json["message"]
    @code = json["code"]
  end

  def to_s
    @message
  end
end
