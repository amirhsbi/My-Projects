import pygame
from config import *

class Player:
    def __init__(self, x, y, images, move_string=None, speed=5):
        self.grid_x = x
        self.grid_y = y
        self.rect = pygame.Rect(*grid_to_pixel(x, y), CELL_SIZE, CELL_SIZE)
        self.images = images
        self.direction = "right"
        self.move_string = move_string
        self.move_index = 0
        self.speed = speed
        self.counter = 0

    def update(self, walls, dt):
            self.counter += dt
            move_interval = 1 / self.speed

            if self.counter < move_interval:
                return
            self.counter = 0

            dx = dy = 0
            if self.move_string is not None:
                if self.move_index >= len(self.move_string):
                    return
                move = self.move_string[self.move_index]
                self.move_index += 1
                if move == "U": dy = -1; self.direction = "up"
                elif move == "D": dy = 1; self.direction = "down"
                elif move == "L": dx = -1; self.direction = "left"
                elif move == "R": dx = 1; self.direction = "right"
                else: dx = 0; dy = 0
            else:
                keys = pygame.key.get_pressed()
                if keys[pygame.K_w] or keys[pygame.K_UP]: dy = -1; self.direction = "up"
                elif keys[pygame.K_s] or keys[pygame.K_DOWN]: dy = 1; self.direction = "down"
                elif keys[pygame.K_a] or keys[pygame.K_LEFT]: dx = -1; self.direction = "left"
                elif keys[pygame.K_d] or keys[pygame.K_RIGHT]: dx = 1; self.direction = "right"

            new_x, new_y = self.grid_x + dx, self.grid_y + dy
            new_rect = pygame.Rect(*grid_to_pixel(new_x, new_y), CELL_SIZE, CELL_SIZE)
            if not any(new_rect.colliderect(w.rect) for w in walls):
                self.grid_x, self.grid_y = new_x, new_y
                self.rect.topleft = grid_to_pixel(self.grid_x, self.grid_y)
                
    def draw(self, screen):
        screen.blit(self.images[self.direction], self.rect.topleft)