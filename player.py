import pygame
from support import import_sprite_sheet


class Player(pygame.sprite.Sprite):
    def __init__(self, pos):
        super().__init__()

        self.import_character_assets()
        self.frame_index = 0
        self.animation_speed = 0.15
        self.image = self.animations['idle'][0]
        self.rect = self.image.get_rect(topleft=pos)

        # movement
        self.direction = pygame.math.Vector2(0, 0)
        self.speed = 4
        self.gravity = 0.8
        self.jump_height = -14


        self.status = "idle"
        self.facing_right = True
        self.on_ground = False
        self.on_ceiling = False
        self.on_left = False
        self.on_right = False

    def import_character_assets(self):
        self.animations = {"idle": [], "run": [], "jump": [], "fall": []}
        folder = "assets/sprites/couscous/"

        for animation in self.animations:
            full_path = folder + animation + ".png"
            self.animations[animation] = import_sprite_sheet(full_path)

    def animate(self):
        animation = self.animations[self.status]
        if not animation:
            animation = self.animations["idle"]
        self.frame_index += self.animation_speed
        if self.status == "jump":
            if self.frame_index >= 1:
                self.frame_index = 1
        elif self.status == "fall":
            self.frame_index *= 0.8
            if self.frame_index >= len(animation):
                self.frame_index = len(animation)

        
        if self.frame_index >= len(animation):
            self.frame_index = 0

        
        image = animation[int(self.frame_index)]
        if self.facing_right:
            self.image = image
        else:
            self.image = pygame.transform.flip(image, True, False)

        if self.on_ground:
            self.rect = self.image.get_rect(midbottom=self.rect.midbottom)
        elif self.on_ceiling:
            self.rect = self.image.get_rect(midtop=self.rect.midtop)
        else:
            self.rect = self.image.get_rect(center=self.rect.center)

    def get_input(self):
        keys = pygame.key.get_pressed()

        if self.on_ground:
            if keys[pygame.K_RIGHT] or keys[pygame.K_d]:
                self.direction.x = 1
                self.facing_right = True
            elif keys[pygame.K_LEFT] or keys[pygame.K_a]:
                self.direction.x = -1
                self.facing_right = False
            else:
                self.direction.x = 0

            if keys[pygame.K_SPACE]:
                if self.direction.x:
                    self.jump("long")
                else:
                    self.jump("high")

    def get_status(self):
        if self.direction.y < 0:
            self.status = "jump"
        elif self.direction.y > 1:
            self.status = "fall"
        else:
            if self.direction.x and self.on_ground:
                self.status = "run"
            else:
                self.status = "idle"

    def apply_gravity(self):
        self.direction.y += self.gravity
        self.rect.y += self.direction.y

    def jump(self, type):
        self.direction.y = self.jump_height
        if type == "long":
            self.direction.x *= 2
            self.direction.y = self.jump_height
        else:
            if self.facing_right:
                self.direction.x = 1
            else:
                self.direction.x = -1
            self.direction.y = self.jump_height - 2

    def apply_camera_offset(self, offset):
        self.rect.centerx -= offset.x
        self.rect.centery -= offset.y

    def update(self):
        self.get_input()
        self.get_status()
        self.animate()
