require_relative './position'

class ForensicsApi
  class InvalidDirection < StandardError
    def initialize(direction)
      super("#{direction} is not an understood direction")
    end
  end

  attr_writer :position, :directions

  def interpret_directions
    directions.each do |direction|
      interpret_direction(direction)
    end
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

  def directions
    @directions ||= raise 'no way to get directions yet'
  end
end
