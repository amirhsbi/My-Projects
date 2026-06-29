from ..environment.game import PacmanGame
from copy import deepcopy
import time

def dfs_solver(game: PacmanGame, timeout=10):
    t0 = time.time()
    if game.is_goal():
        return [game.get_info()]

    stack = [game]
    parent = {game.get_state(): (None, None)}
    obj_map = {game.get_state(): game}
    visited = set()

    while stack:
        if time.time() - t0 > timeout:
            return [game.get_info()]

        cur = stack.pop()
        st = cur.get_state()
        if st in visited:
            continue
        visited.add(st)

        if cur.is_goal():
            rev = []
            while st is not None:
                rev.append(st)
                st = parent[st][0]
            rev.reverse()
            return [obj_map[s].get_info() for s in rev]

        for move, nxt in cur.get_next_states():
            stn = nxt.get_state()
            if stn not in parent:
                parent[stn] = (st, move)
                obj_map[stn] = nxt
            stack.append(nxt)

    return [game.get_info()]
