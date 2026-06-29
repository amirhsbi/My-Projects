from ..environment.game import PacmanGame

def _required_snacks(game: PacmanGame):
    snacks = [s for s in game.snacks if s.exists]
    if not snacks:
        return []
    a_left = [s for s in snacks if s.type == "A"]
    return a_left if a_left else [s for s in snacks if s.type == "B"]

def manhattan(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1])

def h_zero(game: PacmanGame) -> int:
    return 0

def h_max_to_target(game: PacmanGame) -> int:
    targets = _required_snacks(game)
    if not targets:
        return 0
    p = game.player
    return max(manhattan(p, (s.x, s.y)) for s in targets)

def h_mst_plus_min(game: PacmanGame) -> int:
    targets = _required_snacks(game)
    if not targets:
        return 0

    pts = [(s.x, s.y) for s in targets]
    p = game.player

    nearest = min(manhattan(p, t) for t in pts)

    import math
    n = len(pts)
    if n == 1:
        return nearest
    in_mst = [False] * n
    dist = [math.inf] * n
    dist[0] = 0
    total = 0
    for _ in range(n):
        u = min((dist[i], i) for i in range(n) if not in_mst[i])[1]
        in_mst[u] = True
        total += 0 if dist[u] == math.inf else dist[u]
        for v in range(n):
            if not in_mst[v]:
                d = abs(pts[u][0] - pts[v][0]) + abs(pts[u][1] - pts[v][1])
                if d < dist[v]:
                    dist[v] = d

    return nearest + total

DEFAULT_HEURISTIC = h_max_to_target
ALT_HEURISTIC =  h_mst_plus_min     
