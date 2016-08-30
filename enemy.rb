class Enemy

    #SPEED = rand(10)

    attr_reader :x, :y, :radius
    def initialize(window)
        @radius = 25
        @window = window
        @x = rand(@window.width - 2 * @radius) + @radius
        @y = 0
        @image = Gosu::Image.new('images/enemy.png')
        @speed = rand(10) + 1
    end

    def move
        @y += @speed
    end

    def draw
        @image.draw(@x - @radius, @y - @radius, 1)
    end

end
