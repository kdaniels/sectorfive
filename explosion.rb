class Explosion

    DIRECTION = rand(360)
    SPEED = 5
    FRAME_COUNT = 5

    attr_reader :finished, :x, :y, :radius
    def initialize(window, x, y)
        @window = window
        @x = x
        @y = y
        @radius = 30
        @images = Gosu::Image.load_tiles('images/explosion.png', 60, 60)
        @image_index = 0
        @frame_index = 0
        @finished = false
    end

    def draw
        if @frame_index < @images.count * FRAME_COUNT
            @image_index = (@frame_index / FRAME_COUNT).floor
            @images[@image_index].draw(@x - @radius, @y - @radius, 2)
            @frame_index += 1
        else
            @finished = true
        end
    end

    def move
        @x += Gosu.offset_x(DIRECTION, SPEED)
        @y += Gosu.offset_y(DIRECTION, SPEED)
    end

end
