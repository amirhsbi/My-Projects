import pygame
import random
from config import *

class Ghost:
    def __init__(self, x, y, move_dir="horizontal", images=[], speed=5):
        self.grid_x, self.grid_y = x, y
        self.rect = pygame.Rect(*grid_to_pixel(x, y), CELL_SIZE, CELL_SIZE)
        self.move_dir = move_dir
        self.direction = 1
        self.image = random.choice(images) if images else None
        self.speed = speed
        self.slow_counter = 0
        self.move_counter = 0


    def update(self, walls, dt):
        self.slow_counter += dt
        move_interval = 1.0 / self.speed
        if self.slow_counter < move_interval:
            return
        self.slow_counter = 0
        dx = dy = 0
        if self.move_dir == "horizontal": dx = self.direction
        else: dy = self.direction
        new_x, new_y = self.grid_x + dx, self.grid_y + dy
        new_rect = pygame.Rect(*grid_to_pixel(new_x, new_y), CELL_SIZE, CELL_SIZE)
        self.move_counter += self.direction
        if any(new_rect.colliderect(w.rect) for w in walls) or abs(self.move_counter) == GHOST_MOVE_LIMIT:
            self.direction *= -1
            self.update(walls, dt)
        else:
            self.grid_x, self.grid_y = new_x, new_y
            self.rect.topleft = grid_to_pixel(self.grid_x, self.grid_y)

    def draw(self, screen):
        if self.image: screen.blit(self.image, self.rect.topleft)
        else: pygame.draw.rect(screen, RED, self.rect)