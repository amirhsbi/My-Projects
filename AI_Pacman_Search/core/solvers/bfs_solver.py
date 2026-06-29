from collections import deque
from ..environment.game import PacmanGame
import time

def bfs_solver(game: PacmanGame, timeout=10):
    t0 = time.time()
    if game.is_goal():
        return [game.get_info()]

    q = deque([game])
    start_state = game.get_state()
    parent = {start_state: (None, None)}
    obj_map = {start_state: game}

    while q:
        if time.time() - t0 > timeout:
            return [game.get_info()]  

        cur = q.popleft()
        if cur.is_goal():
            st = cur.get_state()
            rev = []
            while st is not None:
                rev.append(st)
                st = parent[st][0]
            rev.reverse()
            return [obj_map[s].get_info() for s in rev]

        for move, nxt in cur.get_next_states():
            stn = nxt.get_state()
            if stn not in parent:
                parent[stn] = (cur.get_state(), move)
                obj_map[stn] = nxt
                q.append(nxt)

    return [game.get_info()]
