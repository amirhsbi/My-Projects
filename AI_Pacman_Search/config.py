""" 
    import your solver functions here
"""
from core.solvers.weighted_astar_solver import weighted_astar_solver
from core.solvers.astar_solver import astar_solver
from core.solvers.bfs_solver import bfs_solver
from core.solvers.dfs_solver import dfs_solver
from core.solvers.ids_solver import ids_solver

CELL_SIZE = 40
AI_MODE_FPS = 3
PLAYER_MODE_FPS = 100
PLAYER_SPEED = 5
P2G_SPEED = 1  # AI speed (moves/sec)
GHOST_MOVE_LIMIT = 2 # Maximum number of cells a ghost can move
PLAYER_SIZE, FRUIT_SIZE, GHOST_SIZE = 40, 50, 40

BLACK  = (0, 0, 0)
WHITE  = (255, 255, 255)
RED    = (255, 0, 0)
BLUE   = (0, 0, 255)
YELLOW = (255, 255, 0)
GREEN = (0, 255, 0)

ROWS = 15
COLS = 20


SOLVER_MODES = ["BFS", "DFS", "IDS", "A*", "Weighted A*"]

"""
    Add your solver functions to SOLVERS dictionary.
"""
SOLVERS = {
    SOLVER_MODES[0]: bfs_solver,
    SOLVER_MODES[1]: dfs_solver,
    SOLVER_MODES[2]: ids_solver,
    SOLVER_MODES[3]: astar_solver,
    SOLVER_MODES[4]: weighted_astar_solver
}

"""
    Set your desired time limits.
"""
TIME_LIMITS = {
    SOLVER_MODES[0]: 200, 
    SOLVER_MODES[1]: 200,
    SOLVER_MODES[2]: 1200,
    SOLVER_MODES[3]: 200,
    SOLVER_MODES[4]: 200
}


def grid_to_pixel(x, y):
    return x * CELL_SIZE, y * CELL_SIZE

def pixel_to_grid(x, y):
    return x // CELL_SIZE, y // CELL_SIZE
