import pygame, os, sys
from settings import *
from level import Level


pygame.init()
screen = pygame.display.set_mode((screen_width, screen_height))
icon = pygame.image.load("assets/TestCous.png")
pygame.display.set_caption('Couscous')
pygame.display.set_icon(icon)
clock = pygame.time.Clock()


bold_font = pygame.font.Font("assets/LibBask_Bold.ttf", 30)
win_text = bold_font.render("Couscous, you won!", True, "White")
lose_text = bold_font.render("Nooo!!! Couscous, you fell!", True, "White")

level = Level(level_0)

def process_game_over(condition):
    if condition == "Win":
        text = win_text
    else:
        text = lose_text
    text_rect = text.get_rect(center=(screen_width/2,screen_height/2))
    screen.fill("Black")
    screen.blit(text, text_rect)
    pygame.display.flip()
    pygame.time.wait(3000)
    pygame.quit()
    sys.exit()


def quitApp():
    if event.type == pygame.QUIT:
        pygame.quit()
        sys.exit()

running = True
while running:
    for event in pygame.event.get():
        quitApp()

    screen.fill("Black")
    level.run()
    if level.game_over:
        running = False
    pygame.display.flip()

    clock.tick(FPS)

process_game_over(level.game_over)
