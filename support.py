import pygame, os
from csv import reader
from settings import tile_size

def import_csv_layout(path):
    data = []
    with open(path) as map:
        level = reader(map,delimiter=",")
        for row in level:
            data.append(list(row))
    return data

def import_tile_set(path):
    if not os.path.exists(path):
        print(f'Path does not exist: {path}')
        return
    surface = pygame.image.load(path).convert_alpha()
    surface = pygame.transform.scale2x(surface)
    tile_num_x = int(surface.get_size()[0] / tile_size)
    tile_num_y = int(surface.get_size()[1] / tile_size)

    cut_tiles = []

    for row in range(tile_num_y):
        for col in range(tile_num_x):
            x = col * tile_size
            y = row * tile_size
            new_surf = pygame.Surface((tile_size,tile_size), pygame.SRCALPHA)
            new_surf.blit(surface,(0,0),pygame.Rect(x,y,tile_size,tile_size))
            cut_tiles.append(new_surf)
    return cut_tiles

def import_sprite_sheet(path):
    if not os.path.exists(path):
        print(f'Path does not exist: {path}')
        return
    sheet = pygame.image.load(path).convert_alpha()
    sheet = pygame.transform.scale2x(sheet)
    width, sprite_size = sheet.get_size()
    tile_num = int(width / sprite_size)

    cut_tiles = []

    for tile_x in range(tile_num):
        x = tile_x * sprite_size
        y = 0
        new_surf = pygame.Surface((sprite_size,sprite_size), pygame.SRCALPHA)
        new_surf.blit(sheet,(0,0),pygame.Rect(x,y,sprite_size,sprite_size))
        cut_tiles.append(new_surf)
    return cut_tiles

def get_player_start(path):
    data = []
    with open(path) as map:
        level = reader(map,delimiter=",")
        for row in level:
            data.append(list(row))

    for row_ind, row in enumerate(data):
        for col_ind, val in enumerate(row):
            if val == "0":
                x, y = col_ind*tile_size, row_ind*tile_size
                return x, y



