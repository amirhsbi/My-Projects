import pygame
import os
from config import *
import re

def natural_sort_key(s):
    """Sort strings like map1.txt, map2.txt, map10.txt in human order."""
    return [int(text) if text.isdigit() else text.lower() for text in re.split(r'(\d+)', s)]


def load_background(image_path, screen_size):
    bg = pygame.image.load(image_path).convert()
    return pygame.transform.scale(bg, screen_size)


def load_fonts(base_size=36):
    try:
        title_font = pygame.font.Font(
            "assets/fonts/PAC-FONT.TTF", base_size + 16)
        menu_font = pygame.font.Font("assets/fonts/PAC-FONT.TTF", base_size)
    except:
        title_font = pygame.font.SysFont("arial", base_size + 16, bold=True)
        menu_font = pygame.font.SysFont("arial", base_size, bold=True)
    return title_font, menu_font


def choose_map(screen, clock, font):
    """Display a map selection menu and return the selected map path."""
    map_folder = "maps"
    maps = [f for f in os.listdir(map_folder) if f.endswith(".txt")]
    if not maps:
        raise FileNotFoundError("No .txt map files found in 'maps' folder.")

    maps.sort(key=natural_sort_key)  # ✅ Fix map1/map10 sorting

    selected = 0
    scroll_offset = 0
    visible_count = 8  # ✅ Number of maps visible at once
    running = True

    background = load_background(
        "assets/menu_bg/PACMAN_MENU.jpg", screen.get_size())
    title_font, menu_font = load_fonts(36)

    while running:
        screen.blit(background, (0, 0))
        title = title_font.render("Choose Map", True, (0, 102, 255))
        screen.blit(title, (COLS * CELL_SIZE //
                    2 - title.get_width() // 2, 50))

        # determine which maps to display
        start_index = scroll_offset
        end_index = scroll_offset + visible_count
        visible_maps = maps[start_index:end_index]

        # draw visible maps
        for i, map_name in enumerate(visible_maps):
            color = GREEN if (start_index + i) == selected else RED
            text = menu_font.render(map_name, True, color)
            screen.blit(text, (COLS * CELL_SIZE // 2 -
                        text.get_width() // 2, 150 + i * 50))

        # scroll indicators
        if scroll_offset > 0:
            up_hint = menu_font.render("↑", True, YELLOW)
            screen.blit(up_hint, (COLS * CELL_SIZE // 2 -
                        up_hint.get_width() // 2, 120))
        if end_index < len(maps):
            down_hint = menu_font.render("↓", True, YELLOW)
            screen.blit(down_hint, (COLS * CELL_SIZE // 2 -
                        down_hint.get_width() // 2, 150 + visible_count * 50))

        pygame.display.flip()
        clock.tick(PLAYER_MODE_FPS)

        # handle events
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
            elif event.type == pygame.KEYDOWN:
                if event.key in (pygame.K_UP, pygame.K_w):
                    selected = (selected - 1) % len(maps)
                elif event.key in (pygame.K_DOWN, pygame.K_s):
                    selected = (selected + 1) % len(maps)
                elif event.key == pygame.K_RETURN:
                    return os.path.join(map_folder, maps[selected])

        # update scroll offset
        if selected < scroll_offset:
            scroll_offset = selected
        elif selected >= scroll_offset + visible_count:
            scroll_offset = selected - visible_count + 1


def main_menu(screen, clock, font):
    """Main menu — choose Player or one of the AI solvers, map, and speed."""
    options = SOLVER_MODES + ["Player"]
    selected = 0
    player_speed = PLAYER_SPEED
    running = True

    # 🎨 Background and fonts
    background = load_background("assets/menu_bg/PACMAN_MENU.jpg", screen.get_size())
    title_font, menu_font = load_fonts(40)

    while running:
        screen.blit(background, (0, 0))

        # 🔵 Blue title
        title = title_font.render("PAC-MAN", True, (0, 102, 255))  # blue
        screen.blit(title, (COLS * CELL_SIZE // 2 - title.get_width() // 2, 50))

        # 🎮 Mode options
        for i, opt in enumerate(options):
            color = GREEN if i == selected else RED
            text = menu_font.render(opt, True, color)
            screen.blit(text, (COLS * CELL_SIZE // 2 - text.get_width() // 2, 150 + i * 60))

        # ⚙️ Speed control
        speed_text = menu_font.render(f"Game Speed: {player_speed} (A/D)", True, WHITE)
        screen.blit(speed_text, (COLS * CELL_SIZE // 2 - speed_text.get_width() // 2, 500))

        pygame.display.flip()
        clock.tick(PLAYER_MODE_FPS)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
            elif event.type == pygame.KEYDOWN:
                if event.key in (pygame.K_UP, pygame.K_w):
                    selected = (selected - 1) % len(options)
                elif event.key in (pygame.K_DOWN, pygame.K_s):
                    selected = (selected + 1) % len(options)
                elif event.key in (pygame.K_a, pygame.K_LEFT):
                    player_speed = max(1, player_speed - 1)
                elif event.key in (pygame.K_d, pygame.K_RIGHT):
                    player_speed = min(PLAYER_MODE_FPS, player_speed + 1)
                elif event.key == pygame.K_RETURN:
                    selected_map = choose_map(screen, clock, font)
                    return options[selected], player_speed, selected_map
