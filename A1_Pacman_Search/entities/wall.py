import pygame
from config import *

class Wall:
    def __init__(self, x, y):
        self.rect = pygame.Rect(*grid_to_pixel(x, y), CELL_SIZE, CELL_SIZE)
    def draw(self, screen):
        pygame.draw.rect(screen, BLUE, self.rect)
