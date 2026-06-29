from ..environment.game import PacmanGame
import time

def ids_solver(game: PacmanGame, max_limit: int = 100000, timeout=10):
    if not hasattr(game, "move_direction"):
        game.move_direction = ""
    t0 = time.time()
    if game.is_goal():
        return [game.get_info()]

    def dls(root: PacmanGame, limit: int):
        local_best_depth = {}
        path_objs = [root]
        path_states = {root.get_state()}

        def dfs(node: PacmanGame, depth: int):
            if time.time() - t0 > timeout:
                return "TIME"
            if node.is_goal():
                return [obj.get_info() for obj in path_objs]
            if depth == limit:
                return None
            for move, nxt in node.get_next_states():
                stn = nxt.get_state()
                if stn in path_states:
                    continue
                prev = local_best_depth.get(stn)
                if prev is not None and prev <= depth + 1:
                    continue
                local_best_depth[stn] = depth + 1
                path_objs.append(nxt)
                path_states.add(stn)
                res = dfs(nxt, depth + 1)
                if isinstance(res, list):
                    return res
                path_states.remove(stn)
                path_objs.pop()
            return None

        return dfs(root, 0)

    depth = 0
    while depth <= max_limit:
        res = dls(game, depth)
        if isinstance(res, list):
            return res
        if res == "TIME":
            return [game.get_info()]
        depth += 1
    return [game.get_info()]
