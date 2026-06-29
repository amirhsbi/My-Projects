from core.environment.map_loader import MapLoader
from core.environment.game import PacmanGame
import time
import pandas as pd
from copy import deepcopy
from tabulate import tabulate
from config import *

"""
    Runs a given 'solver' on a given 'game' and returns output of the 'solver'.
    It sets a time limit on the solver to terminate after reaching it. Change it from config.py
"""
def run_solver(solver, game, timeout=1):
    t1 = time.time()
    moves = solver(deepcopy(game), timeout=timeout)
    t2 = time.time()
    return moves, t2-t1

"""
    Runs each solver on the given map and returns the result in a Pandas.DataFrame.
"""
def run_test(file_path):
    df = pd.DataFrame(columns=['Algorithm', 'Time', 'Numof Moves', "Result"])

    is_wall, player, ghosts, snacks = MapLoader(file_path=file_path).load()
    game = PacmanGame(player=player, ghosts=ghosts, snacks=snacks, is_wall=is_wall, move_direction="")

    for solver_mode in SOLVER_MODES:
        try:
            moves, time = run_solver(solver=SOLVERS[solver_mode], game=deepcopy(game), timeout=TIME_LIMITS[solver_mode])
        except:
            algorithm = solver_mode
            df.loc[len(df)] = [algorithm, time, 0, "Error"]
            continue
        algorithm = solver_mode
        if moves is None:
            df.loc[len(df)] = [algorithm, time, 0, "NotFound"]
        elif len(moves) == 1:
            df.loc[len(df)] = [algorithm, time, 0           , "Timeout"]
        else:
            df.loc[len(df)] = [algorithm, time, len(moves)-1, "Success"]

    df['Time'] = df['Time'].apply(lambda x: f"{x:.2f}")
    return df

"""
    Calls 'run_test' on every test and prints the result of each one.
"""
def run_all_tests():
    for i in range(1, 11):
        result_df = run_test(file_path=f"./maps/map{i}.txt") 
        print(f"Results on map{i}:")       
        print(tabulate(result_df, headers='keys', tablefmt='fancy_grid', showindex=False))
        print()

if __name__ == "__main__":
    from multiprocessing import freeze_support
    freeze_support()
    run_all_tests()