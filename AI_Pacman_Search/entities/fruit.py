import pygame
import random
from config import *


class Fruit:
    def __init__(self, x, y, type="normal", image=None):
        self.grid_x, self.grid_y = x, y
        self.type = type
        self.base_image = image
        self.image = image
        self.rect = pygame.Rect(*grid_to_pixel(x, y), CELL_SIZE, CELL_SIZE)
        self.points = 10 if type == "normal" else 30
        if type == "special":
            self.set_alpha(127)

    def spawn(self, free_cells):
        x, y = random.choice(free_cells)
        self.grid_x, self.grid_y = x, y
        self.rect.topleft = grid_to_pixel(self.grid_x, self.grid_y)

    def set_alpha(self, alpha):
        self.image = self.base_image.copy()
        self.image.set_alpha(alpha)

    def draw(self, screen):
        screen.blit(self.image, self.rect.topleft)