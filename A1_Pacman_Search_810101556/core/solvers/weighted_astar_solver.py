import heapq
from ..environment.game import PacmanGame
from .heuristics import *
import time

def weighted_astar_solver(game: PacmanGame, heuristic_func=None, weight: float = 1.5, timeout=10):
    t0 = time.time()
    if heuristic_func is None:
        heuristic_func = DEFAULT_HEURISTIC

    if game.is_goal():
        return [game.get_info()]

    start_state = game.get_state()
    g = {start_state: 0}
    parent = {start_state: (None, None)}
    obj_map = {start_state: game}

    counter = 0
    h0 = heuristic_func(game)
    pq = [(weight * h0, counter, game)]
    closed = set()  
    
    while pq:
        if time.time() - t0 > timeout:
            return [game.get_info()]

        _, _, cur = heapq.heappop(pq)
        st = cur.get_state()
        if st in closed:
            continue
        closed.add(st)

        if cur.is_goal():
            rev = []
            while st is not None:
                rev.append(st)
                st = parent[st][0]
            rev.reverse()
            return [obj_map[s].get_info() for s in rev]

        g_st = g[cur.get_state()]
        for move, nxt in cur.get_next_states():
            stn = nxt.get_state()
            tentative = g_st + 1
            if stn not in g or tentative < g[stn]:
                g[stn] = tentative
                parent[stn] = (cur.get_state(), move)
                obj_map[stn] = nxt
                hn = heuristic_func(nxt)
                counter += 1
                fval = tentative + weight * hn
                heapq.heappush(pq, (fval, counter, nxt))

    return [game.get_info()]
