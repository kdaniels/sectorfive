class Credit

    SPEED = 1

    attr_reader :y
    def initialize(window, text, x, y)
        @window = window
        @text = text
        @x = x
        @y = @initial_y = y
        @font = Gosu::Font.new(24)
    end

    def move
        @y -= SPEED
    end

    def draw
        @font.draw(@text, @x, @y, 1)
    end

    def reset
        @y = @initial_y
    end

end
