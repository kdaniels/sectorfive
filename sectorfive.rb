require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'

class SectorFive < Gosu::Window

    WIDTH = 800
    HEIGHT = 600

    def initialize
        super(WIDTH, HEIGHT)
        self.caption = "Sector Five"
        @player = Player.new(self)
        @enemies = []
        @bullets = []
        @explosions  = []
        @enemy_frequency = 0.01
        @font = Gosu::Font.new(30)
    end

    def draw
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

    def update
        @player.turn_left if button_down?(Gosu::KbLeft)
        @player.turn_right if button_down?(Gosu::KbRight)
        @player.accelerate if button_down?(Gosu::KbUp)
        @player.backup if button_down?(Gosu::KbDown)
        @player.move
        if rand < @enemy_frequency
            @enemies.push(Enemy.new(self))
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
    end

    def button_down(id)
        if id == Gosu::KbSpace
            @bullets.push(Bullet.new(self, @player.x, @player.y, @player.angle))
        end
    end

end

window = SectorFive.new
window.show
