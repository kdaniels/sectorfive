require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'credit'

class SectorFive < Gosu::Window

    WIDTH = 800
    HEIGHT = 600
    MAX_ENEMIES = 100

    def initialize
        super(WIDTH, HEIGHT)
        self.caption = "Sector Five"
        @font = Gosu::Font.new(30)
        @scene = :start
    end

    def button_down(id)
        case @scene
        when :start
            button_down_start(id)
        when :game
            button_down_game(id)
        when :end
            button_down_end(id)
        end
    end

    def button_down_start(id)
        initialize_game
    end

     def button_down_game(id)
        if id == Gosu::KbSpace
            @bullets.push(Bullet.new(self, @player.x, @player.y, @player.angle))
        end
    end

    def initialize_game
        @player = Player.new(self)
        @enemies = []
        @bullets = []
        @explosions  = []
        @enemy_frequency = 0.01
        @scene = :game
        @enemies_appeared = 0
        @enemies_destroyed = 0
    end

    def initialize_end(fate)
        case fate
        when :count_reached
            @message = "YOU MADE IT! You destroyed #{@enemies_destroyed} enemy ships"
            @message2 = "and #{MAX_ENEMIES-@enemies_destroyed} reached your base."
        when :health_zero
            @message = "Your ship was too damaged by collisions with the enemy."
            @message2 = "Before you died, you took out #{@enemies_destroyed} enemy ships."
        when :off_top
            @message = "You got too close to the enemy mothership."
            @message2 = "Before you died, you took out #{@enemies_destroyed} enemy ships."
        end
        @bottom_message = "Press P to play again or Q to quit."
        @message_font = Gosu::Font.new(28)
        @credits = []
        y = 500
        File.open('credits.txt').each do |line|
            @credits.push(Credit.new(self, line.chomp, 100, y))
            y += 30
        end
        @scene = :end
    end

    def draw
        case @scene
        when :start
            draw_start
        when :game
            draw_game
        when :end
            draw_end
        end
    end

    def draw_start
        font_small = Gosu::Font.new(20)
        font_medium = Gosu::Font.new(30)
        font_large = Gosu::Font.new(55)
        player_image = Gosu::Image.new('images/spaceship.png')
        enemy_image = Gosu::Image.new('images/enemy.png')

        font_small.draw("AS ENEMY SHIPS ATTACK YOUR PLANET IN WAVES,", 150, 30, 2)
        font_small.draw("YOU'VE BEEN ASSIGNED TO PROTECT...", 215, 50, 2)
        font_large.draw("<c=ff0000>SECTOR FIVE</c>", 225, 150, 2)
        font_small.draw("MOVE YOUR SHIP", 75, 275, 2)
        player_image.draw(125, 300, 2)
        font_small.draw("WITH THE ARROW KEYS", 50, 375, 2)
        font_small.draw("SHOOT ENEMY SHIPS",  525, 275, 2)
        enemy_image.draw(600, 300, 2)
        font_small.draw("WITH THE SPACE BAR", 525, 375, 2)
        font_medium.draw("<c=ff0000>PRESS ANY KEY TO START</c>", 215, 525, 2)
    end

    def draw_game
        @player.draw
        @enemies.each do |e|
            e.draw
        end
        @bullets.each do |b|
            b.draw
        end
        @explosions.each do |e|
            e.draw
        end
        @font.draw(@player.health.to_i.to_s, 20, 20, 2)
    end

    def draw_end
        clip_to(50, 140, 700, 360) do
            @credits.each do |credit|
                credit.draw
            end
        end
        draw_line(0,140, Gosu::Color::RED, WIDTH, 140, Gosu::Color::RED)
        @message_font.draw(@message, 40, 40, 1, 1, 1, Gosu::Color::FUCHSIA)
        @message_font.draw(@message2, 40, 75, 1, 1, 1, Gosu::Color::FUCHSIA)
        draw_line(0, 500, Gosu::Color::RED, WIDTH, 500, Gosu::Color::RED)
        @message_font.draw(@bottom_message, 180, 540, 1, 1, 1, Gosu::Color::AQUA)
    end

    def update
        case @scene
        when :game
            update_game
        when :end
            update_end
        end
    end

    def update_game
        @player.turn_left if button_down?(Gosu::KbLeft)
        @player.turn_right if button_down?(Gosu::KbRight)
        @player.accelerate if button_down?(Gosu::KbUp)
        @player.backup if button_down?(Gosu::KbDown)
        @player.move
        if rand < @enemy_frequency
            @enemies.push(Enemy.new(self))
            @enemies_appeared += 1
        end
        @enemies.each do |e|
            e.move
        end
        @bullets.each do |b|
            b.move
        end
        @explosions.each do |e|
            e.move
        end
        @enemies.dup.each do |e|
            @bullets.dup.each do |b|
                distance = Gosu.distance(e.x, e.y, b.x, b.y)
                if distance < e.radius + b.radius
                    @enemies.delete(e)
                    @bullets.delete(b)
                    @explosions.push(Explosion.new(self, e.x, e.y))
                    @enemies_destroyed += 1
                end
                @bullets.delete(b) unless b.onscreen?
            end
            @explosions.each do |en|
                distance = Gosu.distance(e.x, e.y, en.x, en.y)
                if distance < e.radius + en.radius
                    @enemies.delete(e)
                    @explosions.delete(en)
                    @explosions.push(Explosion.new(self, e.x, e.y))
                end
            end
            if e.y > HEIGHT + e.radius
                @enemies.delete(e)
            end
            distance = Gosu.distance(e.x, e.y, @player.x, @player.y)
            if distance < e.radius + @player.radius
                # Since this happens every tick, just make it decrement a very small amount each time
                # to approximate losing ~1 point per enemy collision
                @player.health -= 0.05
            end
        end
        @explosions.dup.each do |e|
            @explosions.delete(e) if e.finished
        end
        if rand < 0.0001
            # Every so often increase the rate at which ships spawn
            @enemy_frequency += 0.01
        end
        initialize_end(:count_reached) if @enemies_appeared > MAX_ENEMIES
        initialize_end(:health_zero) if @player.health <= 0
        initialize_end(:off_top) if @player.y < @player.radius
    end

    def update_end
        @credits.each do |credit|
            credit.move
        end
        if @credits.last.y < 150
            @credits.each do |credit|
                credit.reset
            end
        end
    end

    def button_down_end(id)
        if id == Gosu::KbP
            initialize_game
        elsif id == Gosu::KbQ
            close
        end
    end

end

window = SectorFive.new
window.show
