require 'open-uri'
require 'json'
require_relative './position'

class ForensicsApi
  class InvalidDirection < StandardError
    def initialize(direction)
      super("#{direction} is not an understood direction")
    end
  end

  attr_accessor :directions
  attr_writer :position, :host
  attr_reader :email, :report

  def initialize(email)
    @email = email
  end

  def search
    fetch_directions
    interpret_directions
    guess_location
  end

  def fetch_directions
    response = URI.parse(directions_uri).read
    @directions = JSON.parse(response)['directions']
  end

  def interpret_directions
    directions.each do |direction|
      interpret_direction(direction)
    end
  end

  def guess_location
    response = URI.parse(location_uri).read
    @report = JSON.parse(response)['message']
  end

  def guess_coordinates
    position.coordinates
  end

  private

  def interpret_direction(direction)
    case direction
    when 'left'
      position.left
    when 'right'
      position.right
    when 'forward'
      position.forward
    else
      raise InvalidDirection.new(direction)
    end
  end

  def position
    @position ||= Position.new
  end

  def directions_uri
    api_uri('directions')
  end

  def location_uri
    api_uri('location', [position.x, position.y])
  end

  def api_uri(action, path_params = [])
    uri_elements = [host, 'api', email, action] + path_params
    URI.encode(uri_elements.join('/'))
  end

  def host
    @host ||= 'http://which-technical-exercise.herokuapp.com'
  end
end
