class Position
  attr_reader :direction, :x, :y

  def initialize
    @rotations = 0
    @x = 0
    @y = 0
  end

  def direction
    directions[@rotations % directions.count]
  end

  def right
    @rotations += 1
  end

  def left
    @rotations -= 1
  end

  def forward
    case direction
    when :north
      @y += 1
    when :east
      @x += 1
    when :south
      @y -= 1
    when :west
      @x -= 1
    end
  end

  def coordinates
    "(#{x},#{y})"
  end

  private

  def directions
    @directions ||= %i(north east south west)
  end
end
