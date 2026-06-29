import heapq
from ..environment.game import PacmanGame
from .heuristics import *
from .weighted_astar_solver import weighted_astar_solver

def astar_solver(game: PacmanGame, timeout=10):
    return weighted_astar_solver(game, heuristic_func=DEFAULT_HEURISTIC, weight=1.0, timeout=timeout)
