import pygame
from tiles import StaticTile, AnimatedTile
from player import Player
from settings import *
from support import import_csv_layout, import_tile_set, import_sprite_sheet, get_player_start

class Level:
    def __init__(self, level_data):
        self.display_surface = pygame.display.get_surface()
        self.setup_level(level_data)
        self.camera = pygame.math.Vector2(0, 0)
        self.game_over = False

    def setup_level(self, level_data):
        terrain_layout = import_csv_layout(level_data["terrain"])
        self.terrain_sprites = self.create_tile_group(terrain_layout, "terrain")
        
        treat_layout = import_csv_layout(level_data["treats"])
        self.treat_sprites = self.create_tile_group(treat_layout, "treat")

        self.player = pygame.sprite.GroupSingle()
        player_start_pos = get_player_start(level_data["player"])
        self.player.add(Player(player_start_pos))

    def create_tile_group(self, layout, type):
        sprite_group = pygame.sprite.Group()

        for row_ind, row in enumerate(layout):
            for col_ind, val in enumerate(row):
                if val != "-1":
                    x = col_ind*tile_size
                    y = row_ind*tile_size

                    if type == "terrain":
                        terrain_tiles = import_tile_set("assets/levels/tilesets/BasicTilesetScaled.png")
                        tile_surface = terrain_tiles[int(val)]
                        sprite_group.add(StaticTile((x,y), tile_size, tile_surface))

                    if type == "treat":
                        if val == "0":
                            sprite_group.add(AnimatedTile((x, y), tile_size, "assets/sprites/treats/strawb.png"))
                        if val == "1":
                            pass
                        if val == "2":
                            pass
                        
        return sprite_group

    def get_camera_offset(self):
        player = self.player.sprite
        half_width, half_height = self.display_surface.get_size()[0]//2, self.display_surface.get_size()[1]//2
        self.camera.x = player.rect.centerx - half_width
        self.camera.y = player.rect.centery - half_height

    def check_horizontal_collisions(self):
        player = self.player.sprite
        player.rect.x += player.direction.x * player.speed

        for sprite in self.terrain_sprites.sprites():
            if sprite.rect.colliderect(player.rect):
                if player.direction.x < 0:
                    player.rect.left = sprite.rect.right
                elif player.direction.x > 0:
                    player.rect.right = sprite.rect.left

    def check_vertical_collisions(self):
        player = self.player.sprite
        player.apply_gravity()

        for sprite in self.terrain_sprites.sprites():
            if sprite.rect.colliderect(player.rect):
                if player.direction.y < 0:
                    player.rect.top = sprite.rect.bottom
                    player.direction.y = 0
                    player.on_ceiling = True
                elif player.direction.y > 0:
                    player.rect.bottom = sprite.rect.top
                    player.direction.y = 0
                    player.on_ground = True
        if player.on_ground and player.direction.y < 0 or player.direction.y > 1:
            player.on_ground = False
        if player.on_ceiling and player.direction.y > 0:
            player.on_ceiling = False

    def check_collectible_collisions(self):
        player = self.player.sprite
        for sprite in self.treat_sprites.sprites():
            if sprite.rect.colliderect(player.rect):
                self.treat_sprites.remove(sprite)
                del(sprite)

    def check_game_over(self):
        if not self.treat_sprites:
            self.game_over = "Win"
        if self.player.sprite.rect.y > 400:
            self.game_over = "Lose"


    def run(self):

        self.get_camera_offset()
        self.player.sprite.apply_camera_offset(self.camera)
        self.terrain_sprites.update(self.camera)
        self.terrain_sprites.draw(self.display_surface)
        self.treat_sprites.update(self.camera)
        self.treat_sprites.draw(self.display_surface)
        

        self.player.update()
        self.check_horizontal_collisions()
        self.check_vertical_collisions()
        self.check_collectible_collisions()
        self.player.draw(self.display_surface)

        self.check_game_over()
        