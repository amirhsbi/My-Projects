import pygame
import random
import time
from copy import deepcopy


""""
    In this project, AI mode and player mode are completely seperated, player mode uses entities objects and
    sets up the game independently from AI mode which sets up the game by using MapLoader and PacmanGame objects
    (these classes themself use core.environment objects.)
"""


from config import *   
from menu import main_menu  
from entities.wall import Wall
from entities.player import Player
from entities.fruit import Fruit
from entities.ghost import Ghost

from core.environment.map_loader import MapLoader
from core.environment.game import PacmanGame

def run_solver(solver, game, timeout=10):
    """
        In AI mode:
        This function takes a solver function and runs it on a game object, the result is a history of movement information
        In your solver functions list of PacmanGame.get_info() is returned and used here.
        This info contains the direction of pacman so we can render the correct information, the fruit type (and if it's been eaten or not)
        so we can render the correct picture of fruit, and the positions of pacman and ghosts and fruits to know where to render them in
        the map. We don't need walls positions to be returned because it's static and we have it in main :)
    """
    t1 = time.time()
    info_history = solver(deepcopy(game), timeout=timeout)
    t2 = time.time()
    if t2-t1 > timeout:
        print("The algorithm reached time limit!")
    else:
        print(f"Solver done! It took {t2-t1:.2f} seconds")
    return info_history, t2 - t1

def get_map_history_info(solver_mode, file_path):
    """
        This function takes a solver function and a map's path, calls Maploader on the map's path
        and builds the game object using it's information.
    """
    is_wall, player, ghosts, snacks = MapLoader(file_path=file_path).load()
    game = PacmanGame(player=player, ghosts=ghosts, snacks=snacks, is_wall=is_wall, move_direction="")
    info_history, _ = run_solver(SOLVERS[solver_mode], game=deepcopy(game), timeout=TIME_LIMITS[solver_mode])
    return info_history

def update_render_state(player, ghosts, fruits, direction, info):
    """
        This function extracts the information above and renders them 
    """
    # Player info
    py, px = info[0]
    player.grid_x, player.grid_y = px, py
    player.rect.topleft = (px * CELL_SIZE, py * CELL_SIZE)
    player.direction = {"U": "up", "D": "down", "L": "left", "R": "right"}[direction]

    # Ghosts info
    for i, ghost in enumerate(ghosts):
        gy, gx = info[1 + i]
        ghost.grid_x, ghost.grid_y = gx, gy
        ghost.rect.topleft = (gx * CELL_SIZE, gy * CELL_SIZE)

    # Fruits info
    for i, fruit in enumerate(fruits):
        fy, fx, ftype, fexists = info[1 + len(ghosts) + i]
        fruit.grid_x, fruit.grid_y = fx, fy
        fruit.rect.topleft = (fx * CELL_SIZE, fy * CELL_SIZE)
        fruit.exists = fexists


def draw_all(screen, camera_offset, walls, fruits, ghosts, player):
    """
    Draws all game entities (walls, fruits, ghosts, player) offset by camera position.

    Args:
        screen (pygame.Surface): The game window surface.
        camera_offset (tuple): (cam_x, cam_y) offset values for the camera.
        walls (list): List of Wall objects.
        fruits (list): List of Fruit objects.
        ghosts (list): List of Ghost objects.
        player (Player): The player object.

    Returns:
        None
    """
    cam_x, cam_y = camera_offset

    for wall in walls:
        pygame.draw.rect(screen, BLUE, (wall.rect.x - cam_x,
                         wall.rect.y - cam_y, wall.rect.width, wall.rect.height))

    normal_left = False
    for fruit in fruits:
        if getattr(fruit, "exists", True):
            if fruit.type == "normal":
                normal_left = True
            screen.blit(fruit.image, (fruit.rect.x -
                        cam_x, fruit.rect.y - cam_y))

    if not normal_left:
        for f in fruits:
            f.set_alpha(255)
                
    for ghost in ghosts:
        screen.blit(ghost.image, (ghost.rect.x - cam_x, ghost.rect.y - cam_y))

    screen.blit(player.images[player.direction],
                (player.rect.x - cam_x, player.rect.y - cam_y))


def calculate_camera_offset(player, screen_width, screen_height):
    """
    Calculates camera offset so the player is centered on screen.

    Args:
        player (Player): The player object.
        screen_width (int): Width of the game window.
        screen_height (int): Height of the game window.

    Returns:
        tuple: (cam_x, cam_y) camera offset.
    """
    cam_x = player.rect.centerx - screen_width // 2
    cam_y = player.rect.centery - screen_height // 2
    cam_x = max(cam_x, 0)
    cam_y = max(cam_y, 0)
    return cam_x, cam_y


def main():
    """
    pygame is the graphics library used in this project
    """
    pygame.init()
    screen = pygame.display.set_mode((COLS * CELL_SIZE, ROWS * CELL_SIZE))
    pygame.display.set_caption("Pac-Man AI Visualizer")

    """
        load background music from assets 🎵 
    """
    
    pygame.mixer.init()
    pygame.mixer.music.load("assets/Music/17. Game Play.mp3")
    pygame.mixer.music.set_volume(0.4)  # Adjust volume (0.0 - 1.0)
    pygame.mixer.music.play(-1)  # -1 means loop forever

    clock = pygame.time.Clock()
    font = pygame.font.SysFont(None, 30)

    """
        load images from assets 
    """
    player_images = {
        "up": pygame.transform.scale(pygame.image.load("assets/pacman-up/1.png").convert_alpha(), (PLAYER_SIZE, PLAYER_SIZE)),
        "down": pygame.transform.scale(pygame.image.load("assets/pacman-down/1.png").convert_alpha(), (PLAYER_SIZE, PLAYER_SIZE)),
        "left": pygame.transform.scale(pygame.image.load("assets/pacman-left/1.png").convert_alpha(), (PLAYER_SIZE, PLAYER_SIZE)),
        "right": pygame.transform.scale(pygame.image.load("assets/pacman-right/1.png").convert_alpha(), (PLAYER_SIZE, PLAYER_SIZE)),
    }
    fruit_images = {
        "normal": pygame.transform.scale(pygame.image.load("assets/fruits/apple.png").convert_alpha(), (FRUIT_SIZE, FRUIT_SIZE)),
        "special": pygame.transform.scale(pygame.image.load("assets/fruits/strawberry.png").convert_alpha(), (FRUIT_SIZE, FRUIT_SIZE)),
    }
    ghost_images = [
        pygame.transform.scale(pygame.image.load("assets/ghosts/blinky.png").convert_alpha(), (GHOST_SIZE, GHOST_SIZE)),
        pygame.transform.scale(pygame.image.load("assets/ghosts/clyde.png").convert_alpha(), (GHOST_SIZE, GHOST_SIZE)),
        pygame.transform.scale(pygame.image.load("assets/ghosts/inky.png").convert_alpha(), (GHOST_SIZE, GHOST_SIZE)),
        pygame.transform.scale(pygame.image.load("assets/ghosts/pinky.png").convert_alpha(), (GHOST_SIZE, GHOST_SIZE)),
    ]

    """
        menu returns the selected mode (Player, BFS , ...), player_speed and the path of map.
    """
    mode, player_speed, map_path = main_menu(screen, clock, font)

    def setup_game(map_path):
        """
            In Player mode:
            This function is used to parse the map and create the objects inside the game.
        """
        walls, free_cells, fruits, ghosts = [], [], [], []
        player = None
        with open(map_path, 'r') as f:
            lines = [line.strip() for line in f.readlines() if line.strip()]
        ROWS = len(lines)
        COLS = len(lines[0]) 
        for y, row in enumerate(lines):
            for x, cell in enumerate(row):
                if cell == "W":
                    walls.append(Wall(x, y))
                else:
                    free_cells.append((x, y))
                if cell == "P":
                    player = Player(x, y, player_images,
                                    move_string=None, speed=player_speed)
                    free_cells.remove((x, y))
                elif cell == "A":
                    fruits.append(
                        Fruit(x, y, "normal", fruit_images["normal"]))
                    free_cells.remove((x, y))
                elif cell == "B":
                    fruits.append(
                        Fruit(x, y, "special", fruit_images["special"]))
                    free_cells.remove((x, y))
                elif cell == "H":
                    ghosts.append(Ghost(x, y, "horizontal", random.sample(
                        ghost_images, 2), speed=player_speed / P2G_SPEED))
                    free_cells.remove((x, y))
                elif cell == "V":
                    ghosts.append(Ghost(x, y, "vertical", random.sample(
                        ghost_images, 2), speed=player_speed / P2G_SPEED))
                    free_cells.remove((x, y))
        return walls, free_cells, fruits, ghosts, player

    walls, free_cells, fruits, ghosts, player = setup_game(map_path)
    score, game_over = 0, False
    running = True

    """
        Load AI solution.
    """
    moves = []
    frame_index = 0
    total_frames = 0
    
    if mode != "Player":
        print("Running solver...")
        moves = get_map_history_info(solver_mode=mode, file_path=map_path)
        if moves is not None and moves:
            moves.pop(0)
        else:
            print("Couldn't find a solution. Either the algorithm reached time limit or the search problem was unsolvable!")
            return

        total_frames = len(moves) 
        print("Frames:", len(moves))


    score = 0
    game_over = False
    running = True
    # PLAYER MODE
    if mode == "Player":
        while running:
            dt = clock.tick(PLAYER_MODE_FPS) / 1000.0
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                elif event.type == pygame.KEYDOWN:
                    if game_over and (event.key == pygame.K_RETURN or event.key == pygame.K_SPACE):
                        # restart game
                        walls, free_cells, fruits, ghosts, player = setup_game(map_path)
                        score = 0
                        game_over = False

            screen.fill(BLACK)

            if not game_over:
                player_prev = (player.grid_x, player.grid_y)
                ghost_prev_positions = [(g.grid_x, g.grid_y) for g in ghosts]

                # update player and ghost positions
                player.update(walls, dt)
                for ghost in ghosts:
                    ghost.update(walls, dt)

                for fruit in fruits[:]:
                    # graphically checks collision between player and fruit
                    if player.rect.colliderect(fruit.rect):
                        if fruit.type == "normal":
                            score += fruit.points
                            fruits.remove(fruit)

                        elif fruit.type == "special":
                            normal_left = any(f.type == "normal" for f in fruits)
                            if not normal_left:
                                score += fruit.points
                                fruits.remove(fruit)
                        break

                for ghost, ghost_prev in zip(ghosts, ghost_prev_positions):
                    if player.rect.colliderect(ghost.rect): # graphically checks collision between player and ghost
                        game_over = True
                    elif (player_prev == (ghost.grid_x, ghost.grid_y) and
                        ghost_prev == (player.grid_x, player.grid_y)):
                        game_over = True


            # draw all the objects inside the game
            camera_offset = calculate_camera_offset(
                player, COLS * CELL_SIZE, ROWS * CELL_SIZE)
            draw_all(screen, camera_offset, walls, fruits, ghosts, player)

            score_text = font.render(f"Score: {score}", True, WHITE)
            screen.blit(score_text, (10, 10))

            if game_over:
                messages = ["GAME OVER!", "Press Enter or Space to restart"]
                for i, msg in enumerate(messages):
                    text_surface = font.render(msg, True, RED)
                    text_x = (COLS * CELL_SIZE) // 2 - \
                        text_surface.get_width() // 2
                    text_y = (ROWS * CELL_SIZE) // 2 - (len(messages) *
                                                        font.get_height()) // 2 + i * font.get_height()
                    screen.blit(text_surface, (text_x, text_y))

            pygame.display.flip()

        pygame.quit()

    # AI MODE
    else:
        while running:
            dt = clock.tick(AI_MODE_FPS) / 1000.0
            
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                elif event.type == pygame.KEYDOWN:
                    if game_over and (event.key == pygame.K_RETURN or event.key == pygame.K_SPACE):
                        # Restart game
                        walls, free_cells, fruits, ghosts, player = setup_game(map_path)
                        score = 0
                        game_over = False
                        frame_index = 0

            screen.fill(BLACK)

            if not game_over:

                if total_frames > 0 and frame_index < len(moves):
                    """
                        extract the information of "frame_index" step in history, this information is passed
                        to update_render_state to parse and render the informatiion
                    """
                    direction, info = moves[frame_index]
                    update_render_state(player, ghosts, fruits, direction, info)
                    frame_index += 1
                    
                elif moves and len(moves) > 0:
                    # Stay on last frame
                    direction, info = moves[-1]
                    update_render_state(player, ghosts, fruits, direction, info)


            # Draw all entities
            camera_offset = calculate_camera_offset(
                player, COLS * CELL_SIZE, ROWS * CELL_SIZE)
            draw_all(screen, camera_offset, walls, fruits, ghosts, player)

            # Display game info
            score_text = font.render(f"Score: {score}", True, WHITE)
            screen.blit(score_text, (10, 10))
        
            frame_text = font.render(f"Frame: {frame_index}/{len(moves)}", True, WHITE)
            screen.blit(frame_text, (10, 40))

            if game_over:
                messages = ["GAME OVER!", "Press Enter or Space to restart"]
                for i, msg in enumerate(messages):
                    text_surface = font.render(msg, True, RED)
                    text_x = (COLS * CELL_SIZE) // 2 - text_surface.get_width() // 2
                    text_y = (ROWS * CELL_SIZE) // 2 - (len(messages) * font.get_height()) // 2 + i * font.get_height()
                    screen.blit(text_surface, (text_x, text_y))

            pygame.display.flip()

        pygame.quit()

if __name__ == "__main__":
    main()