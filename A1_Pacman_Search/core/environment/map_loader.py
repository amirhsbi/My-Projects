from ..environment.ghost import Ghost
from ..environment.snack import Snack
from config import GHOST_MOVE_LIMIT

class MapLoader:
    def __init__(self, file_path):
        self.file_path = file_path

    """
        It loads a map placed in the given 'file_path' and returns needed information for the PacmanGame class.
    """
    def load(self):
        with open(self.file_path, 'r') as f:
            lines = [line.strip() for line in f.readlines() if line.strip()]

        height = len(lines)
        width = len(lines[0])

        """ is_wall[i][j] = True indicates that there is a wall on i'th row and j'th column """
        is_wall = [[False] * width for _ in range(height)]
        
        snacks: list[Snack] = []
        ghosts: list[Ghost] = []
        player = None

        for y, row in enumerate(lines):
            for x, ch in enumerate(row):
                if ch == 'W':
                    is_wall[y][x] = True
                elif ch == 'P':
                    player = (y, x)
                elif ch in ['H', 'V']:
                    ghosts.append(Ghost(x=y, y=x, axis=ch, radius=GHOST_MOVE_LIMIT))
                elif ch == ' ':
                    continue
                elif ch in ['A', 'B']:
                    snacks.append(Snack(x=y, y=x, typeOfSnack=ch, exists=True))
                else:
                    print(f"Invalid map character {ch}")

        return is_wall, player, ghosts, snacks
