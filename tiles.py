import pygame
from settings import tile_size
from support import import_sprite_sheet

class Tile(pygame.sprite.Sprite):
    def __init__(self, pos, size):
        super().__init__()
        self.image = pygame.Surface((size,size))
        self.rect = self.image.get_rect(center=(pos[0]+(tile_size/2), pos[1]+(tile_size/2)))

    def update(self, offset):
        self.rect.centerx -= offset.x
        self.rect.centery -= offset.y


class StaticTile(Tile):
    def __init__(self, pos, size, surface):
        super().__init__(pos, size)
        self.image = surface

class AnimatedTile(Tile):
    def __init__(self, pos, size, path):
        super().__init__(pos, size)
        self.frames = import_sprite_sheet(path)
        self.frame_index = 0
        self.image = self.frames[self.frame_index]

    def animate(self):
        self.frame_index += 0.01
        if self.frame_index >= len(self.frames):
            self.frame_index = 0
        self.image = self.frames[int(self.frame_index)]

    def update(self, offset):
        self.animate()
        self.rect.centerx -= offset.x
        self.rect.centery -= offset.y

